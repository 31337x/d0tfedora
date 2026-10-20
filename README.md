# d0tFedora

My preferred Fedora desktop as an installable setup bundle: my full Niri and Noctalia settings, Paradise colors, numbered wallpaper library, apps, hardware controls and login screen.

Requires a regular **Fedora Minimal 44+** installation, an internet connection and a normal user with sudo access. Fedora Atomic/Silverblue/Kinoite are not supported. Prepared on Fedora 44; a complete fresh-install VM test is still outstanding.

## Install

Install Git if needed (`sudo dnf install git`), log in as your regular user and run:

```bash
git clone https://github.com/31337x/d0tFedora.git
cd d0tFedora
bash setup.sh --dry-run
bash setup.sh --yes --quiet-boot
```

Do **not** run `sudo bash setup.sh`; the script elevates only system operations. Reboot when it finishes and select **Niri**.

| Option | Meaning |
| --- | --- |
| `--dry-run` | Print the plan without changes or sudo; does not resolve packages. |
| `--yes` | Accept setup and DNF transactions. Omit to review package changes before final cleanup; autoremove always uses `-y`. |
| `--quiet-boot` | Plymouth spinner and hidden GRUB with a 3-second timeout. |
| `--intel-wifi` | Explicitly install Intel MVM firmware in addition to general firmware. |
| `--help` | Show usage. |

Example for an Intel Wi-Fi laptop:

```bash
bash setup.sh --yes --quiet-boot --intel-wifi
```

Internet connectivity must already work before running the installer. No reboot or interruption of an active desktop is automatic.

## What is installed

- RPM Fusion free/nonfree and Terra repositories, followed by a Fedora package update. The free release RPM uses `download1.rpmfusion.org`, retaining the working download fix.
- Niri, Noctalia, Noctalia Greeter, greetd and Alacritty.
- Nautilus, LocalSend, Mousepad, MPV, imv and Zen Browser.
- btop, fzf, zoxide, Starship, bat, Git, fastfetch, nano, curl and tar.
- FreeRDP and OpenFortiVPN.
- Papirus, adw-gtk3, Plymouth spinner, Noto fonts and JetBrains Mono Nerd Font Mono.
- NetworkManager, Wi-Fi support, PipeWire, WirePlumber, desktop portals, Xwayland Satellite, clipboard tools, Polkit, AccountsService, GNOME Keyring and Linux firmware.
- TuneD and tuned-ppd on desktops and laptops. An existing power-profiles-daemon is replaced through DNF.
- Full FFmpeg from RPM Fusion, replacing ffmpeg-free when installed.

The script removes **Waybar, swaylock and fuzzel** if installed. GNOME Keyring remains installed. Dependency cleanup is deferred until the final system-changing step: `sudo dnf autoremove -y`. This final cleanup automatically accepts removal of packages DNF considers unneeded, including when setup runs without `--yes`.

Adding repositories allows software from those repositories. The documented Terra bootstrap uses `--nogpgcheck` only for the repository-release transaction. Other package transactions retain normal signature checking.

## Exact Niri settings

My Niri configuration is bundled, with only the monitor setup made automatic, including:

- Every keybind, description and category; see [KEYBINDS.md](KEYBINDS.md).
- Mod+K's enabled and bundled `kenn/keybind-cheatsheet` plugin.
- US/Arabic layouts with Alt+Shift switching.
- Automatic monitor resolution/refresh mode and placement, with scale 1 for detected display connectors.
- Touchpad behavior, cursor, gaps, focus ring, shadows, opacity, blur, window rules and hot-corner settings.
- Noctalia startup and the current generated Niri colors.

Saved monitor modes, positions and rotations are removed. Niri enables each connected display with its preferred mode and arranges screens automatically. Setup writes scale-only blocks for DRM connectors detected on the installing machine, including disconnected ports. An additional monitor plugged into one of those ports therefore uses scale 1. A new GPU or dock introducing a previously unseen connector still works automatically, but Niri may choose its own scale until you add a scale-only block. Check connector names with `niri msg outputs`.

The color picker and recording shortcuts remain absent, matching the current configuration.

## Exact Noctalia settings

The full saved `settings.toml` and `bar-labels.toml` are included. This preserves the bar, launcher, panels, clock, brightness preferences, idle behavior, screenshots, lockscreen widget styling, plugin preferences and theme configuration. Your customized compact login widget (400 × 70, with 95% background/input opacity and its saved placement) is used as the FALLBACK widget, so the same appearance applies across screen connector names instead of retaining the default regular layout.

The **Paradise** community palette and installed community template library are included. Enabled template IDs stay as configured in the original settings. Applications those templates target are not all installed by this bundle; for example, a Steam template does not install Steam.

The stored Wallhaven API key is blanked in the shareable copy. Apart from the requested removal of monitor-specific layout and wallpaper assignments, no other settings are intentionally omitted. Home-directory paths are represented by `__HOME__` in the template and rendered to the installing user's actual home directory. Passwords, VPN credentials, history and caches are not part of this bundle.

Preferences for disabled Notes and Wallhaven plugins are preserved even though those plugins are not installed or enabled. Noctalia's validator may report warnings for these saved sections; they are not syntax errors.

The bundled `.bashrc` and custom Fastfetch `config.jsonc` are installed directly, replacing any existing files. Bash includes your aliases, history settings, Fastfetch startup summary, and Starship, zoxide and fzf initialization. Nano is installed for your editor setting and fuzzy file picker. Open a new Bash shell after setup to load these settings. Papirus and adw-gtk3 packages are installed; application theme selections outside Niri/Noctalia are not a full home-directory snapshot. Alacritty starts with JetBrains Mono Nerd Font Mono at size 11.

## Numbered wallpapers and first login

All 25 wallpaper files are bundled as **000–024**, retaining their image extensions. Numbers up to 999 are available for future additions. The current main wallpaper is **`000.jpg`**.

Files install to:

```text
~/Pictures/Wallpapers/000.jpg
~/Pictures/Wallpapers/001.jpg
...
```

The original-to-numbered mapping is recorded in `assets/wallpaper-map.json`. Image contents are unchanged. Noctalia's wallpaper directory, dark/light directories, default and last selection point at the renamed files. Per-monitor wallpaper assignments are removed, so all screens inherit the main wallpaper. Paths are rendered beneath the installing user's home directory.

Setup also copies the main wallpaper to a greeter-readable file in `/var/lib/noctalia-greeter/` and seeds `sync.toml` with the Paradise palette and wallpaper. The greeter therefore has the selected appearance before the first login, without requiring access to a private home directory. The greeter logo is hidden.

Noctalia's automatic greeter-sync preference is preserved. Future synchronization follows the installed helper's authorization requirements; an administrator prompt may be necessary. No blanket passwordless authorization is added. Seeding the initial appearance does not require a running desktop.

The bundled wallpapers are copied directly to `~/Pictures/Wallpapers`, replacing files with matching names.

## Quiet Niri startup that survives updates

Noctalia Greeter discovers system session directories; `~/.local/share/wayland-sessions` is not a normal discovery location for it. A home-only desktop-entry override would therefore not reliably work.

The script installs:

```text
/usr/local/share/wayland-sessions/niri.desktop
/usr/local/bin/niri-session-quiet
~/.config/systemd/user/niri.service.d/quiet.conf
```

The local session is named **Niri**. Noctalia Greeter searches `/usr/local/share` first and suppresses later sessions with the same name, so this entry takes precedence over the packaged one. The launcher executes the packaged `/usr/bin/niri-session` with its terminal output redirected. The home-directory service drop-in sends compositor output to the journal.

These local files survive normal Niri package updates. The script does not edit `/usr/share/wayland-sessions/niri.desktop`. It also does not stop an active session. Diagnostics remain available with:

```bash
journalctl --user -b -u niri.service
```

To undo the quiet session, remove the local desktop entry, local launcher and user drop-in, then run `systemctl --user daemon-reload` and log in again.

## Launcher tweaks

A user override at `~/.local/share/applications/dev.noctalia.Noctalia.desktop` sets `NoDisplay=true`, hiding Noctalia's launcher shortcut while keeping it installed.

MPV's desktop entry is copied into the same user directory and renamed **MPV Media Player**. Delete either user override to restore the packaged entry. User overrides survive updates but do not automatically inherit later desktop-file changes.

## Fresh installation and reruns

This bundle targets a fresh Fedora Minimal installation. It writes the bundled configuration directly and creates no backups. It installs and enables greetd without checking for or disabling an old display manager.

Rerunning reapplies the bundled settings, replacing customizations to affected files. Completed changes remain if a later step fails; fix the reported error and rerun.

## Troubleshooting

For a login-screen failure, switch to a TTY using Ctrl+Alt+F3, sign in and inspect:

```bash
systemctl status greetd
sudo journalctl -b -u greetd
```

To boot into a text login while fixing it:

```bash
sudo systemctl set-default multi-user.target
```

Validate configurations with:

```bash
niri validate
noctalia config validate
```

Power profiles:

```bash
systemctl status tuned tuned-ppd
sudo systemctl enable --now tuned tuned-ppd
```

Package availability and program features can change on future Fedora versions. The script validates against the installed programs before replacing user config. No proprietary GPU drivers, overclocks, custom kernel parameters or GPU-specific codec-driver replacements are automated.

## References and validation

- [Noctalia installation](https://docs.noctalia.dev/noctalia/getting-started/installation/)
- [Greeter installation](https://docs.noctalia.dev/greeter/installation/)
- [Greeter configuration and session discovery](https://docs.noctalia.dev/greeter/configuration/)
- [Greeter appearance sync](https://docs.noctalia.dev/greeter/sync/)
- [Session discovery implementation](https://github.com/noctalia-dev/noctalia-greeter/blob/main/src/greeter/greeter_sessions.cpp)
- [Fedora TuneD integration](https://fedoraproject.org/wiki/Changes/TunedAsTheDefaultPowerProfileManagementDaemon)
- [RPM Fusion](https://rpmfusion.org/Configuration)
- [Niri configuration](https://niri-wm.github.io/niri/Configuration:-Introduction)

See [VALIDATION.md](VALIDATION.md) for checks and known limits. Share the complete archive, not only `setup.sh`.

## Sharing review

See [SHARING-REVIEW.md](SHARING-REVIEW.md) for the pre-publication checks and third-party asset notes.
