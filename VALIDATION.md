# Validation

Cleanup checks:

- Bash/POSIX shell syntax and standalone/embedded Python compilation.
- All JSON and TOML parse successfully.
- Niri configuration validates with the installed Niri.
- Noctalia configuration validates with zero warnings.
- Installer help, dry-run and invalid-option handling.
- Paradise fzf options load and are accepted by fzf.
- Greeter seed generation preserves unrelated settings and removes stale monitor assignments.
- Cheatsheet files and all keyboard shortcuts remain intact.

Not tested end to end: a fresh Fedora installation, package resolution/downloads/removals, reboot, authentication, first-session appearance or later greeter sync. Checks do not install packages or modify the active desktop.
