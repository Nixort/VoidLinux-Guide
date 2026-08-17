# VoidLinux-Guide — XBPS Errors

Use the error text to choose the next check. Do not disable signatures or delete the package database as a first response.

| Error | First check | Likely class |
|---|---|---|
| `Operation not permitted` while fetching metadata | `date`, timezone and NTP service. | Incorrect system time. |
| `Not Found` for repodata | `/etc/xbps.d/*.conf`, architecture and libc. | Wrong repository path. |
| `unresolvable shlib` | Update, repository configuration and orphaned packages. | Stale or removed package state. |
| Changed RSA key prompt | Compare fingerprint with official Void key sources. | Repository key rotation or mismatch. |
| XBPS cannot run at all | Official static XBPS guide. | Broken package manager/runtime. |

## Basic Evidence

```sh
uname -m
cat /etc/os-release
cat /etc/xbps.d/*.conf
sudo xbps-install -S
```

Use `xbps-query -l` to record the installed package state. If the transaction proposes unexpected removals, stop and inspect the dependency reason rather than confirming blindly.

## References

[1] [Common Issues — Void Linux Handbook](https://docs.voidlinux.org/xbps/troubleshooting/common-issues.html)

[2] [Static XBPS — Void Linux Handbook](https://docs.voidlinux.org/xbps/troubleshooting/static.html)
