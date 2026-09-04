# Legacy desktop configs (not deployed via stow)

These packages are kept for reference only. The active Linux desktop stack is
Hyprland + Quickshell + Ghostty (see `make stow` / `STOW_PACKAGES` in the Makefile).

| Package     | Era                          | Replaced by        |
|-------------|------------------------------|--------------------|
| `sway/`     | Sway + waybar + ulauncher    | Hyprland + Quickshell |
| `i3/`       | i3 + rofi + waybar           | Hyprland + Quickshell |
| `alacritty/`| Alacritty terminal           | Ghostty            |
| `wofi/`     | App launcher                 | Quickshell app launcher |
| `alacritty.yml` | Root-level alacritty config | `ghostty/`     |

To deploy a legacy package manually:

```bash
stow --target=$HOME legacy/sway   # example — not recommended on current setup
```
