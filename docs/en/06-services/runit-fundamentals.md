# VoidLinux-Guide — runit Fundamentals

runit supervises services as foreground processes. A service directory normally contains an executable `run` file and may contain `check`, `finish`, `conf` and `log` components.

## Service Locations

| Path | Responsibility |
|---|---|
| `/etc/sv/<service>` | Package-provided service directory. |
| `/var/service/<service>` | Active symlink for the running default runsvdir. |
| `/etc/runit/runsvdir/default/` | Default runsvdir links used when configuring a non-running system. |
| `supervise/` | Runtime supervision state; do not edit it as configuration. |

## Enable a Service

Inspect it first:

```sh
ls -l /etc/sv/<service>
sed -n '1,160p' /etc/sv/<service>/run
```

Enable it:

```sh
sudo ln -s /etc/sv/<service> /var/service/
sudo sv status <service>
```

The link causes runit to start and supervise the service. A service may restart when it exits; that is supervision, not proof that the process is healthy.

## Control a Service

```sh
sudo sv up <service>
sudo sv down <service>
sudo sv restart <service>
sudo sv status <service>
```

`up` requests running state, `down` requests stopped state, `restart` cycles the service, and `status` reports runit state. Use `sv once <service>` for a controlled test before fully enabling a service when the service documentation recommends it.

## Disable a Service Safely

```sh
ls -ld /var/service/<service>
readlink /var/service/<service>
sudo sv down <service>
sudo rm /var/service/<service>
```

This removes the service symlink only. Never delete `/var/service` itself. A real community failure was caused by a malformed `rm` command that removed the entire directory. [1] [2]

## Package Updates

Package updates can replace package-provided service directories. For complex customizations, copy the service directory to a distinct name and manage the replacement according to the Handbook rather than editing package-owned files directly. [1]

## References

[1] [Services and Daemons — Void Linux Handbook](https://docs.voidlinux.org/config/services/index.html)

[2] [Issues with starting NetworkManager on boot — r/voidlinux](https://www.reddit.com/r/voidlinux/comments/yvtyhb/issues_with_starting_networkmanager_on_boot/)
