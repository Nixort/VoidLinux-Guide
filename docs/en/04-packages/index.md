# VoidLinux-Guide — Packages Stage

Void uses **XBPS** (the X Binary Package System), a package manager designed and maintained by the Void Linux project. XBPS installs signed binary packages, resolves dependencies, tracks package ownership and runs package configuration hooks.

## Guides

| Guide | Purpose |
|---|---|
| [How XBPS Works](xbps-concepts.md) | Understand repositories, indexes, transactions and dependencies. |
| [Command Reference](xbps-command-reference.md) | Learn what each common `xbps-*` command does and when to use it. |
| [Repositories](repositories.md) | Understand main, nonfree, multilib, debug and restricted packages. |
| [Advanced Operations](advanced-operations.md) | Holds, repolocks, ignore rules and downgrade boundaries. |
| [Recovery](recovery.md) | Diagnose broken indexes, shlibs, keys and static XBPS scenarios. |

## Golden Rule

Do not copy a package command from another distribution. `apt`, `dnf`, `pacman` and `emerge` solve similar problems with different transaction models. In Void, use the specific `xbps-*` tool that owns the operation and read its man page when the operation can remove, hold, downgrade or reconfigure packages.
