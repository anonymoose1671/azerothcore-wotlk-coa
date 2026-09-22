CLI_DESCRIPTION = """Check the CoA Forge addon without a game client.

Verifies that every file the manifest lists exists, that each Lua file tokenizes with balanced
blocks, strings and brackets, and that the generated catalog is one well formed table.
"""

import argparse
import json
import re
import sys
from pathlib import Path

ADDON = Path(__file__).resolve().parent / 'CoAForge'
MANIFEST = 'CoAForge.toc'
GENERATED = 'Data/Displays.lua'

OPENERS = {'function', 'if', 'do', 'repeat'}
CLOSERS = {'end', 'until'}
KEYWORD = re.compile(r'[A-Za-z_][A-Za-z0-9_]*')
BRACKETS = {')': '(', ']': '[', '}': '{'}


class LuaError(Exception):
    def __init__(self, line, message):
        super().__init__(f'line {line}: {message}')
        self.line = line


def long_bracket(text, index):
    if text[index] != '[':
        return None
    cursor = index + 1
    level = 0
    while cursor < len(text) and text[cursor] == '=':
        level += 1
        cursor += 1
    if cursor < len(text) and text[cursor] == '[':
        return level, cursor + 1
    return None


def skip_long(text, index, level, line):
    close = ']' + '=' * level + ']'
    end = text.find(close, index)
    if end < 0:
        raise LuaError(line, 'unterminated long bracket')
    return end + len(close)


def skip_quoted(text, index, line):
    quote = text[index]
    cursor = index + 1
    while cursor < len(text):
        character = text[cursor]
        if character == '\\':
            cursor += 2
            continue
        if character == '\n':
            raise LuaError(line, 'unterminated string')
        if character == quote:
            return cursor + 1
        cursor += 1
    raise LuaError(line, 'unterminated string')


def check_lua(text):
    depth = 0
    stack = []
    index = 0
    line = 1
    while index < len(text):
        character = text[index]
        if character == '\n':
            line += 1
            index += 1
            continue
        if text.startswith('--', index):
            marker = long_bracket(text, index + 2)
            if marker:
                level, start = marker
                end = skip_long(text, start, level, line)
                line += text.count('\n', index, end)
                index = end
            else:
                index = text.find('\n', index)
                if index < 0:
                    break
            continue
        if character in '"\'':
            index = skip_quoted(text, index, line)
            continue
        marker = long_bracket(text, index)
        if marker and (index == 0 or text[index - 1] not in ']'):
            level, start = marker
            end = skip_long(text, start, level, line)
            line += text.count('\n', index, end)
            index = end
            continue
        if character in '([{':
            stack.append((character, line))
            index += 1
            continue
        if character in ')]}':
            if not stack or stack[-1][0] != BRACKETS[character]:
                raise LuaError(line, f'unmatched {character}')
            stack.pop()
            index += 1
            continue
        match = KEYWORD.match(text, index)
        if match:
            word = match.group(0)
            if word in OPENERS:
                depth += 1
            elif word in CLOSERS:
                depth -= 1
                if depth < 0:
                    raise LuaError(line, f'unexpected {word}')
            index = match.end()
            continue
        index += 1
    if depth != 0:
        raise LuaError(line, f'{depth} block(s) left open')
    if stack:
        character, opened = stack[-1]
        raise LuaError(opened, f'unclosed {character}')
    return line


def manifest_files(addon):
    path = addon / MANIFEST
    if not path.exists():
        raise ValueError(f'missing {MANIFEST}')
    listed = []
    for row in path.read_text(encoding='utf-8').splitlines():
        row = row.strip()
        if not row or row.startswith('##'):
            continue
        listed.append(row.replace('\\', '/'))
    if not listed:
        raise ValueError('the manifest lists no files')
    return listed


def check_catalog(path):
    text = path.read_text(encoding='utf-8')
    blobs = {}
    for name in ('creatureDisplays', 'objectDisplays', 'visualAuras'):
        match = re.search(name + r' = "(.*)",$', text, re.M)
        if not match:
            raise ValueError(f'catalog is missing {name}')
        rows = match.group(1).split('\\n')
        for row in rows:
            if row and not re.match(r'^\d+\\t', row):
                raise ValueError(f'{name} has a malformed row: {row[:40]}')
        blobs[name] = len(rows)
    return blobs


def main(argv=None):
    parser = argparse.ArgumentParser(description=CLI_DESCRIPTION)
    parser.add_argument('--addon', type=Path, default=ADDON)
    args = parser.parse_args(argv)
    report = {'addon': str(args.addon), 'files': {}, 'status': 'passed'}
    try:
        listed = manifest_files(args.addon)
        for relative in listed:
            path = args.addon / relative
            if not path.exists():
                if relative == GENERATED:
                    report['catalog'] = 'not generated; run build_catalog.py'
                    continue
                raise ValueError(f'{MANIFEST} lists a missing file: {relative}')
            lines = check_lua(path.read_text(encoding='utf-8'))
            report['files'][relative] = {'lines': lines, 'bytes': path.stat().st_size}
        for path in sorted(args.addon.rglob('*.lua')):
            relative = path.relative_to(args.addon).as_posix()
            if relative not in listed:
                raise ValueError(f'{relative} is not listed in {MANIFEST}')
        catalog = args.addon / GENERATED
        if catalog.exists():
            report['catalog'] = check_catalog(catalog)
        print(json.dumps(report, indent=2))
        return 0
    except (OSError, ValueError, LuaError) as error:
        report['status'] = 'failed'
        report['error'] = str(error)
        print(json.dumps(report, indent=2), file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
