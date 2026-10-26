# Validation

Current Niri and Noctalia settings sync:

- Saved Niri configuration validates with installed Niri 26.04, including both theme includes.
- Merged Noctalia configuration validates with zero warnings.
- All bundled settings JSON and TOML parse successfully.
- Installer passes Bash syntax checking.
- Home paths use installer-expanded `__HOME__` placeholders.
- Installer copies the soft-border template and all Niri includes; the Steam community template is bundled.

Full installation and greeter behavior were not exercised during this settings sync.
