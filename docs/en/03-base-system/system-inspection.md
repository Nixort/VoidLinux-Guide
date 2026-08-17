# VoidLinux-Guide — System Inspection

Inspection commands answer “what is true now?” before a configuration command changes anything. Run them before asking for help and include only output that contains no secrets.

| Command | What it answers |
|---|---|
| `uname -a` | Kernel and machine information. |
| `uname -m` | Architecture. |
| `cat /etc/os-release` | Distribution identity and release metadata. |
| `id` | Current user and groups. |
| `lsblk -f` | Block devices, filesystems, labels and mount clues. |
| `findmnt` | Current mount tree. |
| `ip addr` | Interfaces and addresses. |
| `ip route` | Routing table. |
| `ss -tulpn` | Listening sockets and owning processes. |
| `df -h` | Filesystem space. |
| `free -h` | Memory and swap state. |
| `sv status /var/service/*` | Enabled runit services. |
| `xbps-query -l` | Installed package set. |

## A Minimal Snapshot

```sh
uname -m
uname -r
cat /etc/os-release
id
findmnt /
df -h /
free -h
ip addr
ip route
```

The point is not to run every command after every change. The point is to select the smallest command that tests the assumption you are about to make. For example, use `findmnt` to verify a mount, not a package reinstall; use `sv status` to verify a service, not a manual daemon launch.

## Redacted Issue Reports

Before sharing output, remove hostnames, usernames, IP addresses, Wi-Fi names, serial numbers, tokens, home-directory names and private paths. Keep error text, package versions and service state when they are relevant.

## References

[1] [Void Linux Handbook](https://docs.voidlinux.org/)

[2] [XBPS Package Manager — Void Linux Handbook](https://docs.voidlinux.org/xbps/index.html)
