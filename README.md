# d0tFedora

A minimal Fedora desktop with Niri, Noctalia, Tokyo Night colors, Codex CLI and the keybind cheatsheet.

Includes the custom Noctalia palettes **Last Horizon**, **Banish**, **Batou**, **Harbor**, **Mecha no Onna** and **Solitude**. Setup installs them to `~/.config/noctalia/palettes`; select them in Noctalia’s custom palette picker. Tokyo Night is the saved active builtin theme; Batou remains the saved custom selection. Last Horizon seeds app colors and the greeter during setup, before Noctalia applies the active theme and synchronizes the greeter.

The saved desktop uses automatic Niri display detection, 7-pixel gaps, 1-pixel borders, disabled focus rings and shadows, and translucent blurred windows. The soft inactive-border template follows Noctalia’s accent color.

The saved lock screen includes a fallback login-box layout with a 500 ms fade. The fallback uses 95% box and input opacity. Wallpaper is the bundled `023.jpg`. **Mod+L** locks immediately; idle locking starts after 10 minutes and screens turn off after 11 minutes.

Before starting Noctalia, the installed startup helper reads Niri’s connected outputs and seeds missing login boxes from the compact fallback template. This applies the saved style on new devices with different display names. Existing monitor layouts are preserved.

Requires a fresh **Fedora Minimal 44+** installation, internet and sudo access. Fedora Atomic is unsupported.

```bash
sudo dnf install git
git clone https://github.com/31337x/d0tfedora.git
cd d0tfedora
bash setup.sh --dry-run
bash setup.sh --yes --quiet-boot
```

Run as your regular user. Reboot when finished and select **Niri**.

Options: `--dry-run`, `--yes`, `--quiet-boot`, `--intel-wifi`, `--help`.

[Keybinds](KEYBINDS.md) · [Validation](VALIDATION.md)

