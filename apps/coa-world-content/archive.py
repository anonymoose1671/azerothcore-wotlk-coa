CLI_DESCRIPTION = """Fetch and verify Ascension archive cache and atlas data into a local gitignored cache."""

import argparse
from datetime import datetime, timezone
import gzip
import hashlib
import io
import json
from pathlib import Path
import sys
import tarfile
import urllib.error
import urllib.request


ROOT = Path(__file__).resolve().parents[2]
DEFAULT_CACHE = ROOT / '.cache/coa-world-content'
DATASET_URL = 'https://raw.githubusercontent.com/hertigservices/ascension-data/main/datasets/cache.json'
PAGES_URL = 'https://hertigservices.github.io/ascension-data/'
TIMEOUT = 300
SAFE_NAME = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-_/'


def safe_relative(path):
    if not path or path.startswith('/') or '..' in path.split('/'):
        raise ValueError(f'Unsafe archive path: {path}')
    if any(character not in SAFE_NAME for character in path):
        raise ValueError(f'Unsafe archive path: {path}')
    return path


def download(url, offline):
    if offline:
        raise ValueError(f'Offline mode; {url} is not cached')
    try:
        with urllib.request.urlopen(url, timeout=TIMEOUT) as response:
            return response.read()
    except urllib.error.URLError as error:
        raise ValueError(f'Cannot fetch {url}: {error}') from None


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_dataset(cache, offline):
    stored = cache / 'cache.json'
    if stored.exists():
        return json.loads(stored.read_text(encoding='utf-8'))
    data = download(DATASET_URL, offline)
    manifest = json.loads(data)
    if manifest.get('schema') != 'ascension-dataset-1':
        raise ValueError('Unsupported dataset schema')
    stored.parent.mkdir(parents=True, exist_ok=True)
    stored.write_bytes(data)
    return manifest


def pack_members(data):
    members = {}
    with tarfile.open(fileobj=io.BytesIO(data)) as archive:
        for member in archive.getmembers():
            if not member.isfile():
                continue
            extracted = archive.extractfile(member)
            if extracted is None:
                continue
            payload = extracted.read()
            members[digest(payload)] = payload
    return members


def fetch_cache_files(manifest, selected, cache, offline):
    release = manifest['release']
    packs = manifest['packs']
    target = cache / release
    wanted = {path: info for path, info in manifest['files'].items()
              if any(path.startswith(prefix) for prefix in selected)}
    if not wanted:
        raise ValueError('No archive files matched the selection')
    needed = {}
    for path, info in wanted.items():
        destination = target / safe_relative(path)
        if destination.exists() and digest(destination.read_bytes()) == info['sha256']:
            continue
        for part in info['parts']:
            needed.setdefault(part['pack'], []).append(path)
    downloaded = {}
    for name in sorted(needed):
        if name not in packs:
            raise ValueError(f'Dataset names an unknown pack: {name}')
        payload = download(packs[name]['url'], offline)
        if digest(payload) != packs[name]['sha256']:
            raise ValueError(f'Pack checksum mismatch: {name}')
        downloaded[name] = pack_members(payload)
    written = []
    for path, info in sorted(wanted.items()):
        destination = target / safe_relative(path)
        if destination.exists() and digest(destination.read_bytes()) == info['sha256']:
            continue
        payload = b''
        for part in info['parts']:
            members = downloaded.get(part['pack'], {})
            if part['sha256'] not in members:
                raise ValueError(f'Pack {part["pack"]} does not carry {path}')
            payload += members[part['sha256']]
        if digest(payload) != info['sha256']:
            raise ValueError(f'Assembled file checksum mismatch: {path}')
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(payload)
        written.append(path)
    return release, sorted(wanted), written


def fetch_atlas(zones, cache, offline):
    target = cache / 'atlas'
    target.mkdir(parents=True, exist_ok=True)
    manifest_path = target / 'atlas-manifest.json.gz'
    if not manifest_path.exists():
        manifest_path.write_bytes(download(PAGES_URL + 'atlas-manifest.json.gz', offline))
    manifest = json.loads(gzip.decompress(manifest_path.read_bytes()))
    if manifest.get('schema') != 'ascension-atlas-1':
        raise ValueError('Unsupported atlas schema')
    written = []
    matched = []
    for zone in manifest['zones']:
        name = (zone.get('name') or '').casefold()
        if zones and not any(term.casefold() in name or term == zone['key'] for term in zones):
            continue
        matched.append(zone['key'])
        relative = zone.get('file')
        if not relative:
            continue
        destination = cache / 'atlas' / safe_relative(relative)
        if destination.exists():
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(download(PAGES_URL + relative, offline))
        written.append(relative)
    return manifest['revision'], matched, written


def record(cache, entry):
    log = cache / 'fetched.json'
    history = json.loads(log.read_text(encoding='utf-8')) if log.exists() else {'schema': 1, 'entries': []}
    history['entries'].append(entry)
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text(json.dumps(history, indent=2) + '\n', encoding='utf-8')


def main(argv=None):
    parser = argparse.ArgumentParser(description=CLI_DESCRIPTION)
    parser.add_argument('command', choices=('cache', 'atlas'))
    parser.add_argument('--select', action='append', default=[])
    parser.add_argument('--zone', action='append', default=[])
    parser.add_argument('--cache', type=Path, default=DEFAULT_CACHE)
    parser.add_argument('--offline', action='store_true')
    args = parser.parse_args(argv)
    try:
        args.cache.mkdir(parents=True, exist_ok=True)
        stamp = datetime.now(timezone.utc).isoformat()
        if args.command == 'cache':
            selected = args.select or ['cachedata/by-mode/conquest-of-azeroth/']
            manifest = read_dataset(args.cache, args.offline)
            release, available, written = fetch_cache_files(manifest, selected, args.cache, args.offline)
            entry = {'command': 'cache', 'at': stamp, 'release': release,
                     'selected': selected, 'files': available, 'downloaded': written}
        else:
            revision, matched, written = fetch_atlas(args.zone, args.cache, args.offline)
            entry = {'command': 'atlas', 'at': stamp, 'revision': revision,
                     'zones': matched, 'downloaded': written}
        record(args.cache, entry)
        print(json.dumps(entry, indent=2))
        return 0
    except (OSError, ValueError, KeyError, tarfile.TarError, json.JSONDecodeError) as error:
        print(f'ERROR: {error}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
