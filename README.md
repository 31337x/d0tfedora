# d0tFedora

A minimal Fedora desktop with Niri, Noctalia, Paradise colors and the keybind cheatsheet.

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
