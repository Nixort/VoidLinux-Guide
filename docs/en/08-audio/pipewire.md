# VoidLinux-Guide — PipeWire Setup

This is the supported minimal PipeWire path. It assumes a working graphical or user session; it does not turn PipeWire into an arbitrary system-level daemon.

## Install

```sh
sudo xbps-install -S pipewire
```

Void's package installs a PipeWire session manager, currently WirePlumber. PipeWire requires an active user D-Bus session and `XDG_RUNTIME_DIR`. [1]

## Configure WirePlumber

If the package examples are not already linked and no conflicting custom configuration exists, create the configuration directory and link the official example:

```sh
mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
ln -s /usr/share/examples/wireplumber/10-wireplumber.conf "$HOME/.config/pipewire/pipewire.conf.d/"
```

If the link already exists, inspect it instead of creating another. Do not keep a stale custom configuration whose only purpose was to disable the old `pipewire-media-session`.

## PulseAudio Compatibility

Most applications use the PulseAudio protocol rather than speaking directly to PipeWire. Configure the official `pipewire-pulse` example if required by the application set:

```sh
mkdir -p "$HOME/.config/pipewire/pipewire.conf.d"
ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf "$HOME/.config/pipewire/pipewire.conf.d/"
```

Install the client diagnostic:

```sh
sudo xbps-install -S pulseaudio-utils
```

## Test in the User Session

Start PipeWire as the user inside the graphical session, not as root:

```sh
pipewire
```

In a second terminal:

```sh
wpctl status
pactl info
```

Use the desktop environment's autostart, XDG Desktop Autostart or the window manager's startup mechanism to launch the working configuration automatically. [1]

## References

[1] [PipeWire — Void Linux Handbook](https://docs.voidlinux.org/config/media/pipewire.html)
