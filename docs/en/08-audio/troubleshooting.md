# VoidLinux-Guide — Audio Troubleshooting

Use the error message to identify the missing layer. Do not reinstall the whole audio stack before checking the session environment.

## D-Bus Errors

A missing system D-Bus socket means the `dbus` service is not running:

```sh
sudo sv status dbus
sudo ln -s /etc/sv/dbus /var/service/
```

A missing session bus means the desktop environment, compositor or shell was not launched with a user D-Bus session. Check:

```sh
printf '%s\n' "$DBUS_SESSION_BUS_ADDRESS"
```

Use the session's supported launcher or `dbus-run-session` for a manually started session.

## Runtime Directory Errors

If PipeWire reports that no runtime directory exists, check:

```sh
printf '%s\n' "$XDG_RUNTIME_DIR"
ls -ld "$XDG_RUNTIME_DIR"
```

Void documents `elogind` or turnstile as ways to create `XDG_RUNTIME_DIR` automatically. Manual runtime-directory setup must use a dedicated directory with mode `700`; do not point the variable at a shared or world-readable location. [1]

## Dummy Output

If only a dummy output is visible:

```sh
wpctl status
pactl info
```

Then check that WirePlumber is running, that the PulseAudio interface was configured if needed, and that a user not using `elogind` belongs to `audio` and `video`. [2]

## Community Trap

Community reports describe PipeWire user services starting with an environment different from the graphical session. If audio works when launched manually but fails at login, prefer the desktop's supported autostart mechanism before creating system-level per-user runit wrappers. [3]

## References

[1] [Session and Seat Management — Void Linux Handbook](https://docs.voidlinux.org/config/session-management.html)

[2] [PipeWire — Void Linux Handbook](https://docs.voidlinux.org/config/media/pipewire.html)

[3] [Getting Pipewire to Work for You — r/voidlinux](https://www.reddit.com/r/voidlinux/comments/141ezlm/getting_pipewire_to_work_for_you_the_kiss_guide/)
