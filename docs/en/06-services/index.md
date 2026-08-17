# VoidLinux-Guide — Services Stage

Void uses runit for service supervision. A service is not enabled because its package is installed; it is enabled when its service directory is linked into the active runsvdir.

## Guides

| Guide | Purpose |
|---|---|
| [runit Fundamentals](runit-fundamentals.md) | Understand service directories, symlinks and `sv`. |
| [Logging](logging.md) | Add and inspect system logging without assuming syslog exists. |
| [Per-User Services](per-user-services.md) | Understand user service environments and D-Bus limitations. |
