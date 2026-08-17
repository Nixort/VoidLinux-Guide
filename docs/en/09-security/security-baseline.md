# VoidLinux-Guide — Security Baseline

Start with the smallest system that solves the task. Every enabled service expands the set of software that can receive input or fail during boot.

## Least Privilege

Use an ordinary user for daily work and `sudo` for individual administrative commands. Review supplementary groups:

```sh
id
groups
```

Do not add `disk`, `input`, `video`, `audio`, `network` or other groups merely because a generic desktop checklist includes them. Add a group only when a specific feature needs it and verify the resulting access.

## Updates

```sh
sudo xbps-install -Su
xcheckrestart
```

Keep the system current and inspect processes using old deleted binaries. Updating does not automatically restart services, so choose service restarts deliberately. [1]

## Review Network Exposure

```sh
ss -tulpn
```

For each listener, identify its package, service, purpose and intended interface. Disable services that are not needed. A firewall is useful, but it does not replace service minimization or updates.

## Remote Administration

Before changing NetworkManager, firewall rules, SSH configuration or display managers over SSH, keep a local console or tested recovery route. Apply one change at a time and verify the connection before closing the old session.

Never publish passwords, private keys, tokens, full private IP inventories or unredacted logs in an issue or community post.

## References

[1] [XBPS Package Manager — Void Linux Handbook](https://docs.voidlinux.org/xbps/index.html)

[2] [Users and Groups — Void Linux Handbook](https://docs.voidlinux.org/config/users-and-groups.html)
