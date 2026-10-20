# Validation

Passed locally:

- Bash syntax and embedded Python syntax checks.
- Installer help, dry-run and unknown-option handling.
- Niri settings retain the original behavior except saved monitor layouts, which are intentionally removed; installation-generated scale-only connector blocks validate.
- Niri configuration validation.
- Noctalia settings retain original preferences with wallpaper renaming, home-path substitution, blanked saved API key, and removal of per-monitor wallpaper assignments. Custom compact lockscreen widget promoted to FALLBACK.
- Noctalia config validation. Two expected warnings refer to retained settings for disabled/uninstalled Notes and Wallhaven plugins.
- All 25 numbered wallpaper files match the originals by SHA-256.
- Numbering begins at 000; 000.jpg is the current default wallpaper.
- Home-path rendering with a different username.
- Initial greeter sync generation in a temporary directory, including wallpaper, Paradise palette and preservation of unrelated existing TOML settings.
- Quiet launcher shell syntax and session entry fields.
- Saved Wallhaven key is absent from every file in the shareable bundle.

The generic desktop-file validator does not recognize the DesktopNames session-entry field. That field is intentionally retained: it is present in the packaged Niri session and read by Noctalia Greeter for XDG_CURRENT_DESKTOP.

Not tested end-to-end: fresh Fedora package resolution, repository/font downloads, actual package removal transactions, reboot, greeter authentication, first-session rendering, future authorized sync and other GPUs. No system packages, live wallpaper files, or active desktop settings were changed while preparing this bundle.

## Installer fixes after user testing

- Bundled Bash and Fastfetch configs match the current user files byte for byte; Bash syntax and Fastfetch config loading pass.
- Setup Bash syntax, embedded Python syntax and dry-run pass after the changes.
- Preserved the user's RPM Fusion free download1 URL fix.
- Added nano for the saved Bash editor/file-picker configuration.
- Final cleanup is explicitly `sudo dnf autoremove -y`; it has not been executed during bundle editing.

A full fresh-install run of this revision is still outstanding.

## Fresh-install simplification

- Removed backup creation and previous display-manager handling. Configuration and wallpapers install directly; greetd is enabled normally.
- Bash syntax, embedded Python syntax and dry-run were checked again. No installation or package cleanup was executed.

## Custom lockscreen widget

- Bundled FALLBACK login widget matches the live eDP-1 customization, including size, placement and every widget setting; only the output identity changes to FALLBACK.
- Parsed TOML comparison confirms unrelated bundled settings are unchanged. No live Noctalia settings were modified.
