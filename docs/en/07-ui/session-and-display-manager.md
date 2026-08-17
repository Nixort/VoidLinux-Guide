# VoidLinux-Guide — Session and Display Manager

A graphical login requires more than a display server. D-Bus, seat management and runtime-directory creation are separate responsibilities.

## D-Bus

Enable the system bus as a runit service:

```sh
sudo sv status dbus
sudo ln -s /etc/sv/dbus /var/service/
```

A graphical application may also need a user session bus. Desktop environments launched through an adequate display manager often create one; a manually launched window manager may need `dbus-run-session`.

```sh
dbus-run-session <window-manager-or-session>
```

Verify the user session:

```sh
printf '%s\n' "$DBUS_SESSION_BUS_ADDRESS"
```

## elogind or seatd

`elogind` provides login, power and runtime-directory features used by many desktop environments and compositors. `seatd` is a smaller seat-management alternative used primarily by wlroots compositors. Choose according to the selected session; do not enable both by habit. [1]

When enabling `elogind`, read the power-management conflict with `acpid`. Both may handle ACPI events; disable `acpid` or configure event handling deliberately. [2]

## Display Manager

A display manager provides a graphical login UI. Install one that matches the selected desktop environment, test its service, and enable only one:

```sh
sudo xbps-install -S <display-manager>
sudo sv status <display-manager>
sudo ln -s /etc/sv/<display-manager> /var/service/
sudo sv status <display-manager>
```

If the display manager fails, disable the link and return to a local TTY. Test the desktop session manually before re-enabling the login UI.

## References

[1] [Session and Seat Management — Void Linux Handbook](https://docs.voidlinux.org/config/session-management.html)

[2] [Power Management — Void Linux Handbook](https://docs.voidlinux.org/config/power-management.html)

[3] [Xorg — Void Linux Handbook](https://docs.voidlinux.org/config/graphical-session/xorg.html)
