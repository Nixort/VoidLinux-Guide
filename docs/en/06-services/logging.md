# VoidLinux-Guide — Logging

A default Void installation does not include a syslog daemon. runit can supervise a service logger, but logging must be installed and enabled intentionally.

## socklog

If you do not have a reason to choose another syslog implementation, the Handbook recommends `socklog-void` as a starting point:

```sh
sudo xbps-install -S socklog-void
sudo ln -s /etc/sv/socklog-unix /var/service/
sudo ln -s /etc/sv/nanoklogd /var/service/
sudo sv status socklog-unix
sudo sv status nanoklogd
```

The logs are stored under `/var/log/socklog/` and `svlogtail` provides convenient access. Reading logs is limited to `root` and users in the `socklog` group. [1]

```sh
sudo svlogtail
```

## Avoid Competing Syslog Daemons

Void also packages `rsyslog` and `metalog`. Do not enable more than one syslog daemon for the same role unless you understand which sockets and files they own.

## Service-Specific Logs

A service may have its own `log` directory and logger. Check the service directory and the package documentation before assuming that every message is in `/var/log`:

```sh
find /etc/sv/<service> -maxdepth 2 -type f -o -type l
sudo sv status <service>
```

## References

[1] [Logging — Void Linux Handbook](https://docs.voidlinux.org/config/services/logging.html)

[2] [Services and Daemons — Void Linux Handbook](https://docs.voidlinux.org/config/services/index.html)
