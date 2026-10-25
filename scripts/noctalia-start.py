#!/usr/bin/env python3
"""Seed login boxes for this machine's outputs before Noctalia starts."""
import copy
import json
import os
import pathlib
import re
import subprocess
import sys
import tomllib


def encode(value):
    if isinstance(value, bool):
        return 'true' if value else 'false'
    return json.dumps(value, ensure_ascii=False)


def prepare(path, outputs):
    text = path.read_text()
    config = tomllib.loads(text)
    layout = config['lockscreen_widgets']
    widgets = layout['widget']
    template = widgets['lockscreen-login-box@FALLBACK']
    additions = []
    order = list(layout.get('widget_order', []))
    for name, output in outputs.items():
        logical = output.get('logical')
        if not logical:
            continue
        if any(w.get('type') == 'login_box' and w.get('output') == name
               for w in widgets.values()):
            continue
        widget = copy.deepcopy(template)
        width, height = logical['width'], logical['height']
        widget['cx'] *= width / widget['placement_width']
        widget['cy'] *= height / widget['placement_height']
        widget.update(output=name, placement_width=width, placement_height=height)
        widget_id = 'lockscreen-login-box@' + name
        while widget_id in widgets:
            widget_id += '-seed'
        widgets[widget_id] = widget
        order.append(widget_id)
        prefix = '[lockscreen_widgets.widget.' + encode(widget_id)
        additions.append(prefix + ']')
        for key, value in widget.items():
            if key != 'settings':
                additions.append(key + ' = ' + encode(value))
        additions.append(prefix + '.settings]')
        additions.extend(key + ' = ' + encode(value) for key, value in widget['settings'].items())
    if additions:
        section = re.search(r'(?m)^\[(?:lockscreen_widgets|"lockscreen_widgets")\]\s*\n', text)
        start = section.end()
        following = re.search(r'(?m)^\[', text[start:])
        end = start + following.start() if following else len(text)
        block = re.sub(r'(?m)^(?:widget_order|"widget_order")\s*=.*$', 'widget_order = ' + encode(order), text[start:end])
        if 'widget_order' not in text[start:end]:
            block += 'widget_order = ' + encode(order) + '\n'
        text = text[:start] + block + text[end:]
        updated = text.rstrip() + '\n\n' + '\n'.join(additions) + '\n'
        tomllib.loads(updated)
        temporary = path.with_name(path.name + '.seed-tmp')
        temporary.write_text(updated)
        temporary.chmod(0o600)
        temporary.replace(path)


def main():
    state = pathlib.Path(os.environ.get('XDG_STATE_HOME', pathlib.Path.home() / '.local/state'))
    path = state / 'noctalia/settings.toml'
    try:
        outputs = json.loads(subprocess.check_output(['niri', 'msg', '--json', 'outputs'], text=True))
        prepare(path, outputs)
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError) as error:
        print(f'Could not seed compact lock screen: {error}', file=sys.stderr)
    os.execvp('noctalia', ['noctalia'])


if __name__ == '__main__':
    main()
