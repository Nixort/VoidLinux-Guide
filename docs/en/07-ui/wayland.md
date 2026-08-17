# VoidLinux-Guide — Wayland

Wayland implementations combine the display server, compositor and window-manager role in one application. The exact package and session command depend on the selected desktop environment or compositor.

## Requirements

A Wayland session needs graphics support and a seat manager. Void documents `elogind` and `seatd` as options for controlling the display and input devices. `XDG_RUNTIME_DIR` is required for the Wayland socket. [1]

Check the current session before troubleshooting applications:

```sh
printf '%s\n' "$WAYLAND_DISPLAY"
printf '%s\n' "$XDG_RUNTIME_DIR"
printf '%s\n' "$XDG_SESSION_TYPE"
```

## Desktop or Standalone Compositor

GNOME and KDE Plasma provide Wayland sessions. Void also packages standalone compositors such as Sway, River, Wayfire, labwc, Niri and others. Choose one route rather than installing every compositor as a test.

The desktop environment or compositor's official Void instructions determine the package set and start command. Do not assume that an Xorg `~/.xinitrc` recipe launches a Wayland compositor.

## X Applications

Applications without native Wayland support can run through XWayland, provided by `xorg-server-xwayland` for most compositors:

```sh
sudo xbps-install -S xorg-server-xwayland
```

Install `qt5-wayland` or `qt6-wayland` for Qt applications when needed. SDL, EFL and Qt applications may require toolkit-specific environment variables; set them only for the affected application or documented session. [1]

## Fonts

Some standalone compositors do not pull in a font package. If applications show missing glyphs or unusable menus, install a suitable font package and verify the application again rather than changing the compositor configuration first.

## References

[1] [Wayland — Void Linux Handbook](https://docs.voidlinux.org/config/graphical-session/wayland.html)

[2] [Session and Seat Management — Void Linux Handbook](https://docs.voidlinux.org/config/session-management.html)
