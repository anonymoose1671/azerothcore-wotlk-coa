CLI_DESCRIPTION = """Install the CoA Forge addon into a World of Warcraft client.

Copies CoAForge into <client>/Interface/AddOns, replacing only files this addon owns.
Nothing else in the client is read or written.
"""

import argparse
import filecmp
import json
import shutil
import sys
from pathlib import Path

SOURCE = Path(__file__).resolve().parent / 'CoAForge'
ADDON_NAME = 'CoAForge'
ALLOWED_SUFFIXES = {'.lua', '.toc', '.xml'}


def collect(source):
    files = []
    for path in sorted(source.rglob('*')):
        if path.is_dir():
            continue
        if path.suffix.lower() not in ALLOWED_SUFFIXES:
            raise ValueError(f'unexpected file in the addon: {path.name}')
        files.append(path.relative_to(source))
    if not files:
        raise ValueError('the addon source is empty')
    return files


def install(source, target, dry_run):
    destination = target / 'Interface' / 'AddOns' / ADDON_NAME
    if not (target / 'Interface').is_dir():
        raise ValueError(f'{target} does not look like a client; no Interface directory')
    written, unchanged = [], []
    for relative in collect(source):
        origin = source / relative
        final = destination / relative
        if final.exists() and filecmp.cmp(origin, final, shallow=False):
            unchanged.append(relative.as_posix())
            continue
        written.append(relative.as_posix())
        if dry_run:
            continue
        final.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(origin, final)
    stale = []
    if destination.is_dir():
        owned = {(destination / relative) for relative in collect(source)}
        for path in sorted(destination.rglob('*')):
            if path.is_file() and path not in owned:
                stale.append(path.relative_to(destination).as_posix())
                if not dry_run:
                    path.unlink()
    return destination, written, unchanged, stale


def main(argv=None):
    parser = argparse.ArgumentParser(description=CLI_DESCRIPTION)
    parser.add_argument('--client', required=True, type=Path, help='Client root, the folder holding Interface')
    parser.add_argument('--source', type=Path, default=SOURCE)
    parser.add_argument('--dry-run', action='store_true')
    args = parser.parse_args(argv)
    try:
        destination, written, unchanged, stale = install(args.source, args.client, args.dry_run)
        print(json.dumps({
            'destination': str(destination),
            'dry_run': args.dry_run,
            'written': written,
            'unchanged': len(unchanged),
            'removed': stale,
        }, indent=2))
        return 0
    except (OSError, ValueError, shutil.Error) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
