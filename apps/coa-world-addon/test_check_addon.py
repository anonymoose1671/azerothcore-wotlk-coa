import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_addon


def rejects(source, hint):
    try:
        check_addon.check_lua(source)
    except check_addon.LuaError as error:
        assert hint in str(error), f'wrong reason for {source!r}: {error}'
        return
    raise AssertionError(f'accepted invalid Lua: {source!r}')


def test_accepts_plain_function():
    check_addon.check_lua('local function add(a, b)\n    return a + b\nend\n')


def test_accepts_every_block_form():
    source = (
        'for index = 1, 3 do print(index) end\n'
        'while true do break end\n'
        'repeat local x = 1 until x == 1\n'
        'if a then b() elseif c then d() else e() end\n'
        'do local scoped = 1 end\n'
    )
    check_addon.check_lua(source)


def test_rejects_missing_end():
    rejects('function broken()\n    return 1\n', 'left open')


def test_rejects_extra_end():
    rejects('local x = 1\nend\n', 'unexpected end')


def test_rejects_unterminated_string():
    rejects('local text = "no closing quote\nlocal y = 2\n', 'unterminated string')


def test_rejects_unmatched_bracket():
    rejects('local t = { 1, 2, 3 )\n', 'unmatched )')


def test_rejects_unclosed_bracket():
    rejects('local t = function(a\nreturn a\nend\n', 'unclosed (')


def test_ignores_keywords_inside_strings():
    check_addon.check_lua('local text = "if then end function do repeat until"\n')


def test_ignores_keywords_inside_line_comments():
    check_addon.check_lua('-- if then end function\nlocal x = 1\n')


def test_ignores_keywords_inside_long_comments():
    check_addon.check_lua('--[[ function if do\nstill a comment end ]]\nlocal x = 1\n')


def test_handles_long_strings():
    check_addon.check_lua('local text = [[function if do end]]\nlocal y = 2\n')


def test_handles_escaped_quotes():
    check_addon.check_lua('local text = "a \\" b"\nlocal y = 2\n')


def test_keyword_prefixes_are_not_keywords():
    check_addon.check_lua('local ending = 1\nlocal functional = 2\nlocal iffy = 3\n')


def test_catalog_rejects_malformed_rows(tmp_path=None):
    import tempfile

    with tempfile.TemporaryDirectory() as folder:
        path = Path(folder) / 'Displays.lua'
        path.write_text('creatureDisplays = "1\\tok",\nobjectDisplays = "2\\tok",\n'
                        'visualAuras = "not-a-row",\n', encoding='utf-8')
        try:
            check_addon.check_catalog(path)
        except ValueError as error:
            assert 'malformed' in str(error)
            return
    raise AssertionError('accepted a malformed catalog row')


def test_catalog_requires_every_blob():
    import tempfile

    with tempfile.TemporaryDirectory() as folder:
        path = Path(folder) / 'Displays.lua'
        path.write_text('creatureDisplays = "1\\tok",\n', encoding='utf-8')
        try:
            check_addon.check_catalog(path)
        except ValueError as error:
            assert 'missing' in str(error)
            return
    raise AssertionError('accepted a catalog with missing blobs')


def test_real_addon_passes():
    assert check_addon.main([]) == 0


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
