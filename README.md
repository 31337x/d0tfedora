# d0tFedora

A minimal Fedora desktop with Niri, Noctalia, Last Horizon colors, Codex CLI and the keybind cheatsheet.

Includes the custom Noctalia palettes **Last Horizon** (default), **Banish**, **Batou**, **Harbor**, **Mecha no Onna** and **Solitude**. Setup installs them to `~/.config/noctalia/palettes`; select them in Noctalia’s custom palette picker. Last Horizon also seeds app colors and the greeter.

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
