#!/usr/bin/env python3
"""Seed mutable greeter appearance from the shipped settings before first login."""
import json
import pathlib
import re
import sys
import tomllib


def encode(value):
    if isinstance(value, bool):
        return 'true' if value else 'false'
    if isinstance(value, str):
        return json.dumps(value, ensure_ascii=False)
    if isinstance(value, (float, int)):
        return repr(value)
    if isinstance(value, dict):
        return '{' + ', '.join(json.dumps(k) + ' = ' + encode(v) for k, v in value.items()) + '}'
    if isinstance(value, list):
        return '[' + ', '.join(encode(item) for item in value) + ']'
    raise TypeError(f'Unsupported TOML value: {type(value).__name__}')


def dump(table, prefix=()):
    lines = []
    if prefix:
        lines.append('[' + '.'.join(json.dumps(k) for k in prefix) + ']')
    for key, value in table.items():
        if not isinstance(value, dict):
            lines.append(json.dumps(key) + ' = ' + encode(value))
    for key, value in table.items():
        if isinstance(value, dict):
            lines.extend(['', dump(value, prefix + (key,))])
    return '\n'.join(lines)


def seed(palette_path, target_path, wallpaper):
    palette = json.loads(pathlib.Path(palette_path).read_text())['dark']
    target = pathlib.Path(target_path)
    state = tomllib.loads(target.read_text()) if target.exists() else {}
    appearance = state.setdefault('appearance', {})
    appearance.update(scheme='Synced', theme_mode='dark')
    appearance['palette'] = {
        re.sub(r'(?<!^)(?=[A-Z])', '_', k[1:]).lower(): v
        for k, v in palette.items() if k.startswith('m') and isinstance(v, str)
    }
    appearance['wallpaper'] = {'path': wallpaper, 'fill_mode': 'crop'}
    appearance.pop('wallpapers', None)
    text = dump(state) + '\n'
    tomllib.loads(text)
    target.write_text(text)


if __name__ == '__main__':
    seed(*sys.argv[1:])
