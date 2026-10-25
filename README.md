# d0tFedora

A minimal Fedora desktop with Niri, Noctalia, Last Horizon colors, Codex CLI and the keybind cheatsheet.

Includes the custom Noctalia palettes **Last Horizon** (default), **Banish**, **Batou**, **Harbor**, **Mecha no Onna** and **Solitude**. Setup installs them to `~/.config/noctalia/palettes`; select them in Noctalia’s custom palette picker. Last Horizon also seeds app colors and the greeter.

The saved lock screen includes the current monitor login-box layouts, a fallback template for other displays, 80% box opacity, 85% input opacity and a 500 ms fade. It uses the bundled `023.jpg` wallpaper and `015.png` avatar. **Mod+L** locks immediately; idle locking starts after 10 minutes and screens turn off after 11 minutes.

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
