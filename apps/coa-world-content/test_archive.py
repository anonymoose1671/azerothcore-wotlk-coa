import io
import sys
import tarfile
from pathlib import Path


sys.path.insert(0, str(Path(__file__).resolve().parent))
import archive


def make_pack(members):
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode='w') as writer:
        for name, payload in members.items():
            info = tarfile.TarInfo(name)
            info.size = len(payload)
            writer.addfile(info, io.BytesIO(payload))
    return buffer.getvalue()


def test_safe_relative_accepts_archive_paths():
    assert archive.safe_relative('cachedata/by-mode/x/questcache.tsv.gz')
    assert archive.safe_relative('atlas/abe10abd7603c222b6ce.json.gz')


def test_safe_relative_rejects_traversal():
    for path in ('../secret', 'a/../../b', '/absolute', '', 'a/..'):
        try:
            archive.safe_relative(path)
        except ValueError:
            continue
        raise AssertionError(f'accepted unsafe path: {path}')


def test_safe_relative_rejects_unexpected_characters():
    for path in ('a b/c', 'drive:\\file', 'semi;colon'):
        try:
            archive.safe_relative(path)
        except ValueError:
            continue
        raise AssertionError(f'accepted unsafe path: {path}')


def test_pack_members_indexes_by_digest():
    payload = b'quest data'
    members = archive.pack_members(make_pack({'anything.bin': payload}))
    assert members == {archive.digest(payload): payload}


def test_pack_members_skips_directories():
    buffer = io.BytesIO()
    with tarfile.open(fileobj=buffer, mode='w') as writer:
        info = tarfile.TarInfo('folder')
        info.type = tarfile.DIRTYPE
        writer.addfile(info)
    assert archive.pack_members(buffer.getvalue()) == {}


def test_download_refuses_network_when_offline():
    try:
        archive.download('https://example.test/x', True)
    except ValueError as error:
        assert 'Offline' in str(error)
        return
    raise AssertionError('offline download did not refuse')


def test_fetch_cache_files_verifies_and_writes(tmp_path=None):
    import tempfile
    payload = b'quest rows'
    pack = make_pack({'member': payload})
    manifest = {
        'release': 'release-1',
        'packs': {'pack-a.tar': {'bytes': len(pack), 'sha256': archive.digest(pack),
                                 'url': 'https://example.test/pack-a.tar'}},
        'files': {'cachedata/by-mode/x/questcache.tsv.gz': {
            'bytes': len(payload), 'sha256': archive.digest(payload),
            'parts': [{'bytes': len(payload), 'pack': 'pack-a.tar', 'sha256': archive.digest(payload)}]}},
    }
    original = archive.download
    archive.download = lambda url, offline: pack
    try:
        with tempfile.TemporaryDirectory() as folder:
            cache = Path(folder)
            release, available, written = archive.fetch_cache_files(manifest, ['cachedata/'], cache, False)
            assert release == 'release-1'
            assert available == ['cachedata/by-mode/x/questcache.tsv.gz']
            assert written == available
            stored = cache / 'release-1/cachedata/by-mode/x/questcache.tsv.gz'
            assert stored.read_bytes() == payload
            _, _, again = archive.fetch_cache_files(manifest, ['cachedata/'], cache, True)
            assert again == []
    finally:
        archive.download = original


def test_fetch_cache_files_rejects_bad_pack_checksum():
    import tempfile
    manifest = {
        'release': 'release-1',
        'packs': {'pack-a.tar': {'bytes': 1, 'sha256': 'deadbeef', 'url': 'https://example.test/p'}},
        'files': {'cachedata/x.gz': {'bytes': 1, 'sha256': 'deadbeef',
                                     'parts': [{'bytes': 1, 'pack': 'pack-a.tar', 'sha256': 'deadbeef'}]}},
    }
    original = archive.download
    archive.download = lambda url, offline: b'not the pack'
    try:
        with tempfile.TemporaryDirectory() as folder:
            archive.fetch_cache_files(manifest, ['cachedata/'], Path(folder), False)
    except ValueError as error:
        assert 'checksum mismatch' in str(error)
        return
    finally:
        archive.download = original
    raise AssertionError('bad pack checksum was accepted')


def test_fetch_cache_files_requires_a_match():
    import tempfile
    manifest = {'release': 'r', 'packs': {}, 'files': {'other/x.gz': {'bytes': 0, 'sha256': '', 'parts': []}}}
    try:
        with tempfile.TemporaryDirectory() as folder:
            archive.fetch_cache_files(manifest, ['cachedata/'], Path(folder), True)
    except ValueError as error:
        assert 'matched' in str(error)
        return
    raise AssertionError('empty selection was accepted')


def main():
    failures = 0
    for name, test in sorted(globals().items()):
        if not name.startswith('test_') or not callable(test):
            continue
        try:
            test()
        except AssertionError as error:
            failures += 1
            print(f'FAIL {name}: {error}')
        else:
            print(f'PASS {name}')
    print('FAILED' if failures else 'OK')
    return 1 if failures else 0


if __name__ == '__main__':
    sys.exit(main())
