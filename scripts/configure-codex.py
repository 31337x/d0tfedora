#!/usr/bin/env python3
"""Select Noctalia syntax colors while retaining existing Codex settings."""
import pathlib
import re
import sys
import tomllib


def configure(path):
    path = pathlib.Path(path)
    text = path.read_text() if path.exists() else ''
    expected = tomllib.loads(text)
    expected.setdefault('tui', {})['theme'] = 'noctalia'
    # Edit the usual [tui] table without rewriting unrelated user settings.
    section = re.search(r'(?m)^\[tui\][ \t]*(?:#.*)?$', text)
    if section:
        following = re.search(r'(?m)^[ \t]*\[', text[section.end():])
        end = section.end() + following.start() if following else len(text)
        block = text[section.end():end]
        theme = r'(?m)^[ \t]*theme\s*=.*$'
        block = re.sub(theme, 'theme = "noctalia"', block) if re.search(theme, block) else '\ntheme = "noctalia"\n' + block
        text = text[:section.end()] + block + text[end:]
    else:
        text = text.rstrip() + '\n\n[tui]\ntheme = "noctalia"\n'
    # Refuse unusual TOML layouts rather than overwrite unrelated settings.
    if tomllib.loads(text) != expected:
        raise ValueError('Could not safely update Codex tui.theme')
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text.lstrip('\n'))


if __name__ == '__main__':
    configure(sys.argv[1])
