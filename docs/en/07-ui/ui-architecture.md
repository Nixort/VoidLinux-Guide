# VoidLinux-Guide — UI Architecture

A graphical session is not one package. It is a chain of responsibilities:

| Layer | Responsibility |
|---|---|
| Kernel and firmware | Detect hardware and load low-level support. |
| Mesa or vendor driver | Provide rendering and hardware acceleration. |
| Xorg or Wayland compositor | Provide the display protocol and rendering path. |
| Seat/session manager | Provide device access, login state and runtime directories. |
| Desktop environment or window manager | Arrange windows and provide the user shell. |
| Display manager or `startx` | Start the graphical session. |
| Portals and applications | Integrate screenshots, file dialogs and desktop services. |

Void's graphical-session documentation requires graphics drivers and either Xorg or Wayland; session management may also be needed. [1]

## Choose the Route

Choose Xorg when you need a traditional display server and broad compatibility. Choose Wayland when the chosen desktop environment or compositor supports your hardware, input and application stack. Do not install both routes as if they were a single server; many systems can contain both, but each login session must select one deliberately.

## Verify the Session

Inside a graphical session, inspect:

```sh
printf '%s\n' "$DISPLAY"
printf '%s\n' "$WAYLAND_DISPLAY"
printf '%s\n' "$XDG_RUNTIME_DIR"
printf '%s\n' "$DBUS_SESSION_BUS_ADDRESS"
```

A working graphic does not prove that D-Bus, `XDG_RUNTIME_DIR` or audio session integration is correct. Verify each layer before continuing to PipeWire or desktop autostart.

## References

[1] [Graphical Session — Void Linux Handbook](https://docs.voidlinux.org/config/graphical-session/index.html)

[2] [Session and Seat Management — Void Linux Handbook](https://docs.voidlinux.org/config/session-management.html)
