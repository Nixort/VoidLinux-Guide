# VoidLinux-Guide — UI and Audio Troubleshooting

A graphical failure may be a driver, display protocol, seat, session bus or user-runtime problem. Audio adds PipeWire and WirePlumber on top of that chain.

## Session Snapshot

```sh
printf '%s\n' "$DISPLAY"
printf '%s\n' "$WAYLAND_DISPLAY"
printf '%s\n' "$XDG_RUNTIME_DIR"
printf '%s\n' "$DBUS_SESSION_BUS_ADDRESS"
```

Missing `XDG_RUNTIME_DIR` or a user D-Bus address can explain both UI integration and PipeWire failures. Check `elogind`, `seatd`, the display manager and the launch method before reinstalling applications. [1]

## PipeWire Snapshot

```sh
wpctl status
pactl info
```

If only a dummy output appears, confirm that WirePlumber is running, the user session bus exists, `XDG_RUNTIME_DIR` is valid and the `audio`/`video` groups are present when `elogind` is not used. [2]

## UI Snapshot

For Xorg:

```sh
grep -E -m1 '\(II\) modeset\([0-9]+\):' /var/log/Xorg.0.log
```

For Wayland:

```sh
printf '%s\n' "$WAYLAND_DISPLAY"
printf '%s\n' "$XDG_SESSION_TYPE"
```

Change one layer at a time and keep a local TTY available.

## References

[1] [Session and Seat Management — Void Linux Handbook](https://docs.voidlinux.org/config/session-management.html)

[2] [PipeWire — Void Linux Handbook](https://docs.voidlinux.org/config/media/pipewire.html)

[3] [Wayland — Void Linux Handbook](https://docs.voidlinux.org/config/graphical-session/wayland.html)
