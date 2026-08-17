# VoidLinux-Guide — Xorg

Xorg is the traditional display-server route. Void provides a broad `xorg` package and a smaller `xorg-minimal` package; the minimal route requires you to choose fonts, terminal, input and window-manager components yourself.

## Full Xorg Route

For a general free-driver system, the complete package is the safer starting point:

```sh
sudo xbps-install -S xorg
```

The package includes the server, free video and input drivers, fonts and base applications. Hardware requiring a proprietary driver needs the corresponding vendor guide and may require `nonfree`. [1]

## Minimal Route

`xorg-minimal` contains the base server only. A usable session will also need a font package, terminal emulator, window manager or desktop environment and input support:

```sh
sudo xbps-install -S xorg-minimal xorg-fonts xterm <window-manager>
```

Do not use this command unchanged: choose the window manager and input path for the actual system.

## Start an X Session

The `xinit` package provides `startx`. Add the session command as the final line of `~/.xinitrc`:

```sh
printf '%s\n' 'exec <window-manager>' > "$HOME/.xinitrc"
startx
```

Test this from a local TTY first. If the session fails, inspect the exact error and `/var/log/Xorg.0.log` instead of installing another display manager.

## Driver Verification

Xorg normally auto-detects drivers. If modesetting is deliberately configured, verify it using the official log pattern:

```sh
grep -E -m1 '\(II\) modeset\([0-9]+\):' /var/log/Xorg.0.log
```

## Display Manager Boundary

A display manager provides a graphical login UI. Void packages include `gdm`, `sddm` and `lightdm`; test the service before enabling it and avoid enabling multiple display managers simultaneously. [1]

## References

[1] [Xorg — Void Linux Handbook](https://docs.voidlinux.org/config/graphical-session/xorg.html)

[2] [Graphics Drivers — Void Linux Handbook](https://docs.voidlinux.org/config/graphical-session/graphics-drivers/index.html)
