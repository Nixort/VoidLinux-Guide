# VoidLinux-Guide — Per-User Services

Per-user runit services are useful for user-owned daemons such as SSH tunnels or agents. They are not automatically equivalent to applications launched inside a graphical session.

## The Environment Limitation

The official Handbook warns that system-level runsvdir services started at boot may not have access to the user's graphical session or D-Bus session bus. This is why a user service can report `run` while a graphical application still cannot connect to its session.

Do not use per-user runit as the first fix for PipeWire, a desktop autostart application or a GUI agent. First use the session's supported autostart mechanism and verify `DBUS_SESSION_BUS_ADDRESS` and `XDG_RUNTIME_DIR`.

## Basic Service Directory

A user can place service directories under a personal directory such as `~/service`. A service requires an executable `run` file that starts the process in the foreground. Use the current per-user services Handbook page for the complete runsvdir setup and environment handling. [1]

## Inspect the Environment

```sh
printf '%s\n' "$HOME"
printf '%s\n' "$USER"
printf '%s\n' "$DBUS_SESSION_BUS_ADDRESS"
printf '%s\n' "$XDG_RUNTIME_DIR"
```

If required variables are absent, do not add a system-level runit wrapper blindly. Decide whether the service belongs in a login session, desktop autostart, turnstile or a system service.

## Control a User Service

When `SVDIR` points to the user's service directory:

```sh
SVDIR="$HOME/service" sv status '*'
SVDIR="$HOME/service" sv restart <service>
```

Keep user service names and paths distinct from system services. Test the foreground command directly before asking runit to supervise it.

## References

[1] [Per-User Services — Void Linux Handbook](https://docs.voidlinux.org/config/services/user-services.html)

[2] [Session and Seat Management — Void Linux Handbook](https://docs.voidlinux.org/config/session-management.html)
