CLI_DESCRIPTION = """Build the CoA Forge addon catalog from client DBC data and the world database.

Writes CoAForge/Data/Displays.lua: creature displays, gameobject displays and pure visual auras,
each as a tab separated blob the addon searches in game. No game data is committed.
"""

import argparse
import json
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
ADDON = Path(__file__).resolve().parent / 'CoAForge'
HEADER = struct.Struct('<4sIIII')
MAGIC = b'WDBC'

APPLY_AURA = 6
AURA_DUMMY = 4
INFINITE_DURATION = 21

CREATURE_DISPLAY_ID = 0
CREATURE_DISPLAY_MODEL = 1
CREATURE_DISPLAY_SCALE = 4
CREATURE_MODEL_ID = 0
CREATURE_MODEL_NAME = 2
OBJECT_DISPLAY_ID = 0
OBJECT_DISPLAY_NAME = 1


class Dbc:
    def __init__(self, path):
        data = path.read_bytes()
        magic, self.records, self.fields, self.record_bytes, string_bytes = HEADER.unpack_from(data, 0)
        if magic != MAGIC:
            raise ValueError(f'{path.name} is not a WDBC file')
        start = HEADER.size
        end = start + self.records * self.record_bytes
        if len(data) < end + string_bytes:
            raise ValueError(f'{path.name} is truncated')
        self.body = data[start:end]
        self.strings = data[end:end + string_bytes]

    def rows(self):
        for index in range(self.records):
            yield self.body[index * self.record_bytes:(index + 1) * self.record_bytes]

    def uint(self, row, field):
        return struct.unpack_from('<I', row, field * 4)[0]

    def real(self, row, field):
        return struct.unpack_from('<f', row, field * 4)[0]

    def uint_at(self, row, offset):
        return struct.unpack_from('<I', row, offset)[0]

    def text(self, row, field):
        return self.text_at(row, field * 4)

    def text_at(self, row, offset):
        start = struct.unpack_from('<I', row, offset)[0]
        if start == 0 or start >= len(self.strings):
            return ''
        end = self.strings.find(b'\x00', start)
        return self.strings[start:end if end >= 0 else len(self.strings)].decode('utf-8', 'replace')


def model_label(path):
    name = path.replace('\\', '/').rsplit('/', 1)[-1]
    return name.rsplit('.', 1)[0]


def spell_offsets(repo):
    sys.path.insert(0, str(repo / 'apps/coa-dbc'))
    import schemas

    columns = {field.name: field.offset for field in schemas.spell_schema(schemas.ROOT).columns}
    required = ('Effect[0]', 'Effect[1]', 'Effect[2]', 'EffectApplyAuraName[0]',
                'DurationIndex', 'SpellName[enUS]', 'Description[enUS]', 'SpellVisual[0]')
    missing = [name for name in required if name not in columns]
    if missing:
        raise ValueError('Spell schema is missing fields: ' + ', '.join(missing))
    return {name: columns[name] for name in required}


def visual_auras(dbc_dir, repo):
    offsets = spell_offsets(repo)
    spell = Dbc(dbc_dir / 'Spell.dbc')
    found = []
    for row in spell.rows():
        if spell.uint_at(row, offsets['Effect[0]']) != APPLY_AURA:
            continue
        if spell.uint_at(row, offsets['Effect[1]']) or spell.uint_at(row, offsets['Effect[2]']):
            continue
        if spell.uint_at(row, offsets['EffectApplyAuraName[0]']) != AURA_DUMMY:
            continue
        if spell.uint_at(row, offsets['DurationIndex']) != INFINITE_DURATION:
            continue
        if not spell.uint_at(row, offsets['SpellVisual[0]']):
            continue
        if spell.text_at(row, offsets['Description[enUS]']).strip():
            continue
        name = spell.text_at(row, offsets['SpellName[enUS]']).strip()
        if not name:
            continue
        found.append((spell.uint(row, 0), name))
    found.sort(key=lambda item: item[1].lower())
    return found


def creature_displays(dbc_dir, names):
    models = {}
    model_data = Dbc(dbc_dir / 'CreatureModelData.dbc')
    for row in model_data.rows():
        models[model_data.uint(row, CREATURE_MODEL_ID)] = model_label(
            model_data.text(row, CREATURE_MODEL_NAME))
    display = Dbc(dbc_dir / 'CreatureDisplayInfo.dbc')
    found = []
    for row in display.rows():
        display_id = display.uint(row, CREATURE_DISPLAY_ID)
        used_by = names.get(display_id)
        if not used_by:
            continue
        model = models.get(display.uint(row, CREATURE_DISPLAY_MODEL), '')
        scale = display.real(row, CREATURE_DISPLAY_SCALE)
        label = used_by if not model else f'{used_by} [{model}]'
        if scale and abs(scale - 1.0) > 0.001:
            label = f'{label} x{scale:.2f}'
        found.append((display_id, label))
    found.sort(key=lambda item: item[1].lower())
    return found


def object_displays(dbc_dir, names):
    display = Dbc(dbc_dir / 'GameObjectDisplayInfo.dbc')
    found = []
    for row in display.rows():
        display_id = display.uint(row, OBJECT_DISPLAY_ID)
        used_by = names.get(display_id)
        if not used_by:
            continue
        model = model_label(display.text(row, OBJECT_DISPLAY_NAME))
        found.append((display_id, f'{used_by} [{model}]' if model else used_by))
    found.sort(key=lambda item: item[1].lower())
    return found


def query(mysql, connection, sql):
    argv = [str(mysql), f'--host={connection.host}', f'--port={connection.port}',
            f'--user={connection.user}', f'--password={connection.password}',
            '--batch', '--raw', '--skip-column-names',
            f'--database={connection.database}', f'--execute={sql}']
    result = subprocess.run(argv, capture_output=True, text=True)
    if result.returncode:
        raise ValueError(result.stderr.strip())
    return [line.split('\t') for line in result.stdout.splitlines() if line]


def display_names(mysql, connection):
    creature_sql = ("SELECT m.CreatureDisplayID, MIN(t.name) FROM creature_template_model m "
                    "JOIN creature_template t ON t.entry = m.CreatureID "
                    "WHERE t.name <> '' GROUP BY m.CreatureDisplayID")
    object_sql = ("SELECT displayId, MIN(name) FROM gameobject_template "
                  "WHERE displayId > 0 AND name <> '' GROUP BY displayId")
    creatures = {int(row[0]): row[1] for row in query(mysql, connection, creature_sql) if row[1]}
    objects = {int(row[0]): row[1] for row in query(mysql, connection, object_sql) if row[1]}
    return creatures, objects


def blob(rows):
    return '\\n'.join(f'{identifier}\\t{escape(label)}' for identifier, label in rows)


def escape(text):
    cleaned = ''.join(' ' if character < ' ' or character == '\x7f' else character
                      for character in text)
    return cleaned.replace('\\', '\\\\').replace('"', '\\"').strip()


def render(creatures, objects, auras):
    lines = [
        'CoAForgeData = {',
        f'    generated = "{len(creatures)} displays, {len(objects)} object displays, '
        f'{len(auras)} visual effects",',
        f'    creatureDisplays = "{blob(creatures)}",',
        f'    objectDisplays = "{blob(objects)}",',
        f'    visualAuras = "{blob(auras)}",',
        '}',
        '',
    ]
    return '\n'.join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(description=CLI_DESCRIPTION)
    parser.add_argument('--config', required=True, help='worldserver.conf holding WorldDatabaseInfo')
    parser.add_argument('--mysql', required=True, help='Path to the mysql client')
    parser.add_argument('--dbc', required=True, help='Directory holding the client DBC files')
    parser.add_argument('--output', type=Path, default=ADDON / 'Data/Displays.lua')
    parser.add_argument('--repo', type=Path, default=ROOT)
    args = parser.parse_args(argv)
    try:
        sys.path.insert(0, str(args.repo / 'apps/coa-gameplay-test'))
        import run

        connection = run.Connection.parse(run.read_config(args.config)['WorldDatabaseInfo'])
        creature_names, object_names = display_names(args.mysql, connection)
        dbc_dir = Path(args.dbc)
        creatures = creature_displays(dbc_dir, creature_names)
        objects = object_displays(dbc_dir, object_names)
        auras = visual_auras(dbc_dir, args.repo)
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(render(creatures, objects, auras), encoding='utf-8')
        print(json.dumps({
            'output': str(args.output),
            'creature_displays': len(creatures),
            'object_displays': len(objects),
            'visual_auras': len(auras),
            'bytes': args.output.stat().st_size,
        }, indent=2))
        return 0
    except (OSError, ValueError, KeyError, ImportError, struct.error) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
