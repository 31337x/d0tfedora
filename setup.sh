#!/usr/bin/env bash
# Fedora Minimal -> Niri + Noctalia. Run as your regular user.
set -Eeuo pipefail
trap 'printf "\nSetup stopped at line %s. Fix the error above and rerun.\n" "$LINENO" >&2' ERR
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
ASSUME_YES=0
DRY_RUN=0
QUIET_BOOT=0
INTEL_WIFI=0
for arg in "$@"; do
    case "$arg" in
        --yes) ASSUME_YES=1 ;;
        --dry-run) DRY_RUN=1 ;;
        --quiet-boot) QUIET_BOOT=1 ;;
        --intel-wifi) INTEL_WIFI=1 ;;
        -h|--help)
            cat <<'HELP'
Usage: bash setup.sh [--yes] [--dry-run] [--quiet-boot] [--intel-wifi]
  --yes          Accept setup and DNF prompts.
  --dry-run      Print the plan without changing files or requesting sudo.
  --quiet-boot   Set Plymouth spinner and hide GRUB (3-second timeout).
  --intel-wifi   Install Intel MVM Wi-Fi firmware.
Run as the normal desktop user, never with sudo bash setup.sh.
HELP
            exit 0 ;;
        *) printf 'Unknown option: %s\n' "$arg" >&2; exit 2 ;;
    esac
done
[[ $EUID -ne 0 ]] || { echo 'Run as your regular sudo-enabled user.' >&2; exit 1; }
# shellcheck source=/etc/os-release
source /etc/os-release
[[ $ID == fedora && $VERSION_ID =~ ^[0-9]+$ && $VERSION_ID -ge 44 ]] || {
    echo 'Requires standard Fedora 44 or newer (DNF-based, not Atomic).' >&2; exit 1;
}
[[ ! -e /run/ostree-booted ]] || { echo 'Fedora Atomic is not supported.' >&2; exit 1; }
[[ -r $SCRIPT_DIR/config/niri/config.kdl && -r $SCRIPT_DIR/config/niri/noctalia.kdl ]]
cat <<'PLAN'
This setup will:
  • Add RPM Fusion free/nonfree and Terra repositories; update Fedora.
  • Install Niri, Noctalia, its greeter, apps, fonts, audio and desktop services.
  • Install GNOME Keyring login integration and Passwords and Keys.
  • Install full FFmpeg; configure power profiles and NetworkManager.
  • Install the user's Niri config and greetd's config.
  • Apply the full saved Niri and Noctalia settings, with automatic displays.
  • Install Bash, Fastfetch, Codex CLI and Noctalia colors.
  • Copy wallpapers to ~/Pictures/Wallpapers and restore selections.
  • Install the bundled keybind cheatsheet plugin for Mod+K.
  • Hide Noctalia's launcher entry and rename MPV and Btop++ launcher entries.
  • Enable greetd for the next boot.
  • Finish with sudo dnf autoremove -y to remove unneeded packages.
Existing sessions are not stopped. Waybar, swaylock and fuzzel are removed; GNOME Keyring stays. No automatic reboot.
PLAN
printf 'Quiet boot: %s; Intel Wi-Fi firmware: %s\n' "$QUIET_BOOT" "$INTEL_WIFI"
(( DRY_RUN == 0 )) || exit 0
if (( ! ASSUME_YES )); then
    read -r -p 'Apply this setup? [y/N] ' answer
    [[ $answer == y || $answer == Y ]] || exit 0
fi
sudo -v
DNF=(sudo dnf)
(( ! ASSUME_YES )) || DNF+=(-y)
"${DNF[@]}" install ca-certificates curl python3
if ! rpm -q rpmfusion-free-release >/dev/null 2>&1; then
    "${DNF[@]}" install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-${VERSION_ID}.noarch.rpm"
fi
if ! rpm -q rpmfusion-nonfree-release >/dev/null 2>&1; then
    "${DNF[@]}" install "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-${VERSION_ID}.noarch.rpm"
fi
if ! rpm -q terra-release >/dev/null 2>&1; then
    # Official Noctalia instructions bootstrap Terra this way. Only this
    # repository-release transaction bypasses package signature checking.
    "${DNF[@]}" install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
fi
"${DNF[@]}" upgrade --refresh
packages=(
    noctalia noctalia-greeter greetd niri alacritty
    plymouth-theme-spinner papirus-icon-theme adw-gtk3-theme
    btop fzf zoxide starship nautilus localsend mousepad mpv imv zen-browser
    bat tar nano freerdp openfortivpn git fastfetch fontconfig desktop-file-utils
    google-noto-sans-arabic-vf-fonts google-noto-naskh-arabic-vf-fonts
    google-noto-color-emoji-fonts google-noto-sans-symbols-vf-fonts
    google-noto-sans-math-fonts google-noto-sans-vf-fonts
    google-noto-serif-vf-fonts google-noto-sans-mono-vf-fonts
    NetworkManager NetworkManager-wifi wireplumber pipewire pipewire-pulseaudio
    pipewire-alsa xdg-desktop-portal-gnome xdg-desktop-portal-gtk
    # greetd already includes PAM hooks; this module unlocks the keyring at login.
    xdg-user-dirs polkit gnome-keyring gnome-keyring-pam seahorse accountsservice
    wl-clipboard xwayland-satellite linux-firmware firewalld
)
"${DNF[@]}" install "${packages[@]}"
# Replace an existing PPD provider instead of installing conflicting daemons.
if rpm -q power-profiles-daemon >/dev/null 2>&1; then
    "${DNF[@]}" swap power-profiles-daemon tuned-ppd
fi
"${DNF[@]}" install tuned tuned-ppd
remove_packages=()
for package in waybar swaylock fuzzel; do
    if rpm -q "$package" >/dev/null 2>&1; then remove_packages+=("$package"); fi
done
if (( ${#remove_packages[@]} )); then
    "${DNF[@]}" remove --setopt=clean_requirements_on_remove=False "${remove_packages[@]}"
fi
if (( INTEL_WIFI )); then "${DNF[@]}" install iwlwifi-mvm-firmware; fi
if rpm -q ffmpeg-free >/dev/null 2>&1; then
    "${DNF[@]}" swap ffmpeg-free ffmpeg --allowerasing
else
    "${DNF[@]}" install ffmpeg --allowerasing
fi
# Stage and validate before touching the existing configuration.
STAGE=$(mktemp -d)
trap 'rm -rf -- "$STAGE"' EXIT
cp "$SCRIPT_DIR/config/niri/"*.kdl "$STAGE/"
niri validate --config "$STAGE/config.kdl"
python3 - "$SCRIPT_DIR/config/noctalia/settings.toml" "$STAGE/settings.toml" "$HOME" <<'PY'
import json, pathlib, sys, tomllib
text = pathlib.Path(sys.argv[1]).read_text()
text = text.replace('__HOME__', json.dumps(sys.argv[3], ensure_ascii=False)[1:-1])
tomllib.loads(text)
pathlib.Path(sys.argv[2]).write_text(text)
PY
noctalia config validate "$STAGE/settings.toml"
# Install Codex as the desktop user, without Node.js or npm.
curl --fail --location --retry 3 'https://chatgpt.com/codex/install.sh' -o "$STAGE/install-codex.sh"
sh "$STAGE/install-codex.sh"
mkdir -p "$HOME/.config/fastfetch"
install -m 0644 "$SCRIPT_DIR/config/bash/bashrc" "$HOME/.bashrc"
install -m 0644 "$SCRIPT_DIR/config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
mkdir -p "$HOME/.local/state/noctalia" "$HOME/.config/alacritty"
# Install the bundled wallpaper library.
mkdir -p "$HOME/Pictures/Wallpapers"
cp -a "$SCRIPT_DIR/assets/Wallpapers/." "$HOME/Pictures/Wallpapers/"
PLUGIN_DIR="$HOME/.local/state/noctalia/plugins/materialized/community/keybind-cheatsheet"
mkdir -p "$PLUGIN_DIR"
cp -a "$SCRIPT_DIR/assets/plugins/materialized/community/keybind-cheatsheet/." "$PLUGIN_DIR/"
install -m 0600 "$STAGE/settings.toml" "$HOME/.local/state/noctalia/settings.toml"
mkdir -p "$HOME/.config/noctalia"
install -m 0644 "$SCRIPT_DIR/config/noctalia/bar-labels.toml" "$HOME/.config/noctalia/bar-labels.toml"
mkdir -p "$HOME/.config/noctalia/palettes"
cp -a "$SCRIPT_DIR/config/noctalia/palettes/." "$HOME/.config/noctalia/palettes/"
DEFAULT_PALETTE="$SCRIPT_DIR/config/noctalia/palettes/Last Horizon.json"
mkdir -p "$HOME/.local/state/noctalia/community-palettes"
install -m 0644 "$SCRIPT_DIR/assets/community-palettes/Kitten.json" "$HOME/.local/state/noctalia/community-palettes/Kitten.json"
TEMPLATE_DIR="$HOME/.local/state/noctalia/community-templates"
mkdir -p "$TEMPLATE_DIR" "$HOME/.codex/themes" "$HOME/.config/fzf/themes"
cp -a "$SCRIPT_DIR/assets/community-templates/." "$TEMPLATE_DIR/"
noctalia theme --theme-json "$DEFAULT_PALETTE" \
    --default-mode dark \
    -r "$TEMPLATE_DIR/codex/codex.tmTheme:$HOME/.codex/themes/noctalia.tmTheme" \
    -r "$TEMPLATE_DIR/fzf/fzf.sh:$HOME/.config/fzf/themes/noctalia.sh" > /dev/null
python3 "$SCRIPT_DIR/scripts/configure-codex.py" "$HOME/.codex/config.toml"
install -m 0644 "$SCRIPT_DIR/config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
mkdir -p "$HOME/.local/bin"
install -m 0755 "$SCRIPT_DIR/scripts/noctalia-start.py" "$HOME/.local/bin/noctalia-start.py"
mkdir -p "$HOME/.config/niri" "$HOME/.local/share/applications" "$HOME/.local/share/fonts"
install -m 0644 "$STAGE/"*.kdl "$HOME/.config/niri/"
xdg-user-dirs-update
mkdir -p "$HOME/Pictures/Screenshots"
cat > "$HOME/.local/share/applications/dev.noctalia.Noctalia.desktop" <<'DESKTOP'
[Desktop Entry]
Type=Application
Name=Noctalia
Exec=noctalia --daemon
Icon=noctalia
NoDisplay=true
DESKTOP
if [[ -f /usr/share/applications/mpv.desktop ]]; then
    sed 's/^Name=.*/Name=MPV Media Player/' /usr/share/applications/mpv.desktop > "$HOME/.local/share/applications/mpv.desktop"
fi
if [[ -f /usr/share/applications/btop.desktop ]]; then
    sed 's/^Name=.*/Name=Btop++/' /usr/share/applications/btop.desktop > "$HOME/.local/share/applications/btop.desktop"
fi
update-desktop-database "$HOME/.local/share/applications"
FONT="$HOME/.local/share/fonts/JetBrainsMonoNLNerdFontMono-Regular.ttf"
if [[ ! -s $FONT ]]; then
    curl --fail --location --retry 3 \
        'https://raw.githubusercontent.com/ryanoasis/nerd-fonts/v3.4.0/patched-fonts/JetBrainsMono/NoLigatures/Regular/JetBrainsMonoNLNerdFontMono-Regular.ttf' \
        -o "$STAGE/font.ttf"
    install -m 0644 "$STAGE/font.ttf" "$FONT"
fi
fc-cache -f
# Configure a new greeter using the account shipped by Fedora's greetd package.
GREETER_USER=$(python3 - <<'PY'
import pathlib, tomllib
p = pathlib.Path('/etc/greetd/config.toml')
s = tomllib.loads(p.read_text()) if p.exists() else {}
print(s.get('default_session', {}).get('user', 'greetd'))
PY
)
id "$GREETER_USER" >/dev/null
GREETER_GROUP=$(id -gn "$GREETER_USER")
GREETER_BIN=$(command -v noctalia-greeter-session)
sudo install -d -m 0755 /etc/greetd
python3 - "$GREETER_BIN" "$GREETER_USER" > "$STAGE/greetd.toml" <<'PY'
import json, sys
print('[terminal]\nvt = 1\n\n[default_session]')
print('command = ' + json.dumps(sys.argv[1]))
print('user = ' + json.dumps(sys.argv[2]))
PY
sudo install -m 0644 "$STAGE/greetd.toml" /etc/greetd/config.toml
printf 'd /var/lib/noctalia-greeter 0750 %s %s -\n' "$GREETER_USER" "$GREETER_GROUP" > "$STAGE/tmpfiles.conf"
sudo install -m 0644 "$STAGE/tmpfiles.conf" /etc/tmpfiles.d/noctalia-greeter.conf
sudo systemd-tmpfiles --create noctalia-greeter.conf
sudo env GREETER_USER="$GREETER_USER" noctalia-greeter-apply-appearance --setup-system
# Preserve greeter options while selecting the seeded appearance.
sudo python3 - <<'PYCODE'
import pathlib, re, tomllib
p = pathlib.Path('/var/lib/noctalia-greeter/greeter.toml')
s = p.read_text()
if not re.search(r'(?m)^\[appearance\][ \t]*$', s):
    s += '\n[appearance]\n'
section = re.search(r'(?m)^\[appearance\][ \t]*$', s)
start = section.end()
following = re.search(r'(?m)^\[', s[start:])
end = start + following.start() if following else len(s)
block = s[start:end]
for key, value in [('hide_logo', 'true'), ('scheme', '"Synced"')]:
    pattern = r'(?m)^[ \t]*' + key + r'\s*=.*$'
    line = key + ' = ' + value
    block = re.sub(pattern, line, block) if re.search(pattern, block) else '\n' + line + '\n' + block
s = s[:start] + block + s[end:]
tomllib.loads(s)
p.write_text(s)
PYCODE
# Seed synchronized appearance before the first login. Future Noctalia syncs
# update sync.toml; no fixed wallpaper/palette override is added to greeter.toml.
MAIN_WALLPAPER=$(python3 - "$STAGE/settings.toml" <<'PY'
import sys, tomllib
with open(sys.argv[1], 'rb') as f:
    print(tomllib.load(f)['wallpaper']['default']['path'])
PY
)
GREETER_WALLPAPER="/var/lib/noctalia-greeter/wallpaper.${MAIN_WALLPAPER##*.}"
sudo install -o "$GREETER_USER" -g "$GREETER_GROUP" -m 0640 "$MAIN_WALLPAPER" "$GREETER_WALLPAPER"
sudo python3 "$SCRIPT_DIR/scripts/seed-greeter.py" \
    "$DEFAULT_PALETTE" \
    /var/lib/noctalia-greeter/sync.toml "$GREETER_WALLPAPER"
sudo chown "$GREETER_USER:$GREETER_GROUP" /var/lib/noctalia-greeter/sync.toml
sudo chmod 0640 /var/lib/noctalia-greeter/sync.toml
# Local files take precedence in Noctalia Greeter and survive RPM updates.
sudo install -d -m 0755 /usr/local/bin /usr/local/share/wayland-sessions
sudo install -m 0755 "$SCRIPT_DIR/scripts/niri-session-quiet" /usr/local/bin/niri-session-quiet
sudo install -m 0644 "$SCRIPT_DIR/config/niri.desktop" /usr/local/share/wayland-sessions/niri.desktop
# Keep compositor-service messages in the journal rather than the login VT.
mkdir -p "$HOME/.config/systemd/user/niri.service.d"
cat > "$HOME/.config/systemd/user/niri.service.d/quiet.conf" <<'UNIT'
[Service]
StandardOutput=journal
StandardError=journal
UNIT
systemctl --user daemon-reload
if (( QUIET_BOOT )); then
    sudo plymouth-set-default-theme -R spinner
    sudo python3 - <<'PY'
import pathlib, re
p = pathlib.Path('/etc/default/grub')
s = p.read_text()
for key, value in [('GRUB_TIMEOUT', '3'), ('GRUB_TIMEOUT_STYLE', 'hidden')]:
    pattern = r'(?m)^' + key + r'=.*$'
    line = key + '=' + value
    s = re.sub(pattern, line, s) if re.search(pattern, s) else s + '\n' + line + '\n'
p.write_text(s)
PY
    sudo grub2-mkconfig -o /boot/grub2/grub.cfg
fi
sudo systemctl enable --now NetworkManager tuned tuned-ppd accounts-daemon firewalld
# Enable these for the next login; a TTY may have no user bus yet.
systemctl --user enable pipewire.socket pipewire-pulse.socket wireplumber.service
sudo systemctl enable greetd.service
sudo systemctl set-default graphical.target
xdg-mime default imv.desktop image/png image/jpeg image/webp image/gif image/bmp image/tiff
sudo firewall-cmd --permanent --add-port=53317/tcp
sudo firewall-cmd --permanent --add-port=53317/udp
sudo firewall-cmd --reload
# Final system-changing step, after packages, configuration and services.
sudo dnf autoremove -y
printf '\nSetup complete.\n'
printf 'Reboot when ready, choose Niri, then configure Noctalia appearance.\n'
printf 'Your wallpapers and Mod+K cheatsheet are included.\n'
