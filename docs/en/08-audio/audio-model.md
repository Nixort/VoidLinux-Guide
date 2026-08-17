# VoidLinux-Guide — Audio Model

Use the correct layer when diagnosing sound:

| Layer | Responsibility | Typical check |
|---|---|---|
| ALSA | Kernel-facing hardware and device access. | `aplay -l` when `alsa-utils` is installed. |
| PipeWire | User-space audio/video graph and stream server. | `wpctl status`. |
| WirePlumber | PipeWire session manager and routing policy. | `wpctl status` shows a running session. |
| `pipewire-pulse` | PulseAudio-compatible protocol for applications. | `pactl info`. |
| Desktop mixer | User interface for volume and routes. | Desktop-specific control. |

Installing PipeWire does not mean that every user-session prerequisite is configured. Void requires a user D-Bus session and `XDG_RUNTIME_DIR`; without `elogind`, `audio` and `video` group access may be needed. [1]

## Do Not Stack Audio Servers

If replacing PulseAudio, remove or stop the old PulseAudio service according to the package state before enabling the PipeWire PulseAudio interface. Do not run two servers that claim the same device and socket.

## Diagnostic Order

1. Confirm the hardware exists with ALSA tools.
2. Confirm the user session has D-Bus and `XDG_RUNTIME_DIR`.
3. Confirm WirePlumber is running through `wpctl status`.
4. Confirm the PulseAudio interface with `pactl info` if configured.
5. Only then change profiles, mixers or application settings.

## References

[1] [PipeWire — Void Linux Handbook](https://docs.voidlinux.org/config/media/pipewire.html)
