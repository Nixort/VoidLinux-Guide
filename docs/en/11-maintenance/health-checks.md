# VoidLinux-Guide — Health Checks

Run checks that answer a concrete operational question. A health check should produce an actionable result, not a large log dump that nobody reads.

## Recommended Checks

```sh
sudo xbps-install -Su
xcheckrestart
uname -r
df -h
free -h
ip route
ss -tulpn
sudo sv status /var/service/*
sudo vkpurge list
```

Interpret the output by layer:

| Check | Investigates |
|---|---|
| XBPS update | Package and repository state. |
| `xcheckrestart` | Processes using old binaries. |
| `df -h` | Full filesystems, especially `/boot` and `/var`. |
| `free -h` | Memory and swap pressure. |
| `ip route` | Default route and interface ownership. |
| `ss -tulpn` | Network exposure. |
| `sv status` | Service supervision state. |
| `vkpurge list` | Removable old kernels. |

## Before Asking for Help

Capture the relevant command, exact error, package version, kernel version, service status and the change that preceded the failure. Redact secrets and private network information.

## References

[1] [XBPS Package Manager — Void Linux Handbook](https://docs.voidlinux.org/xbps/index.html)

[2] [Services and Daemons — Void Linux Handbook](https://docs.voidlinux.org/config/services/index.html)

[3] [Kernel — Void Linux Handbook](https://docs.voidlinux.org/config/kernel.html)
