# VoidLinux-Guide — XBPS Command Reference

This reference explains the responsibility of each common XBPS command. The command name is not enough: flags determine whether XBPS searches, synchronizes, installs, updates, removes or repairs state.

## Common Commands

| Command | Responsibility | Example | Important detail |
|---|---|---|---|
| `xbps-install` | Install packages, synchronize indexes and upgrade installed packages. | `sudo xbps-install -Su` | `-S` syncs indexes; `-u` upgrades; package names request installation. |
| `xbps-query` | Inspect installed packages or search repositories. | `xbps-query -Rs pattern` | `-R` searches repositories; without it, queries local state. |
| `xbps-remove` | Remove installed packages and optionally orphaned dependencies. | `sudo xbps-remove -o package` | Read the removal transaction before accepting. |
| `xbps-reconfigure` | Run package configuration hooks again. | `sudo xbps-reconfigure -f package` | `-f` forces reconfiguration. |
| `xbps-alternatives` | Select among packages providing an alternative implementation. | `sudo xbps-alternatives -l` | Set only an alternative you understand. |
| `xbps-pkgdb` | Inspect or modify package database state. | `xbps-pkgdb -a` | Holds and repolocks change future transactions. |
| `xbps-rindex` | Manage a local binary package repository/index. | `xbps-rindex -a file.xbps` | Used in advanced local-package workflows. |
| `xlocate` | Search the cached index of files provided by repositories. | `xlocate filename` | Provided by `xtools`; avoids downloading every package. |
| `xcheckrestart` | Find processes using old deleted binaries after updates. | `xcheckrestart` | Provided by `xtools`; run as an unprivileged user. |
| `vkpurge` | List or remove old kernel files and modules. | `sudo vkpurge list` | It is not a replacement for removing kernel packages. |

## Search and Inspect Before Install

```sh
xbps-query -Rs '<pattern>'
xbps-query -S '<package>'
```

The first command searches the repository index. The second displays package metadata when the package is available. Use the package name from the result, not the name of a command from a different distribution.

## Install and Update

```sh
sudo xbps-install -S <package>
sudo xbps-install -Su
```

The first command synchronizes indexes and installs the named package. The second synchronizes indexes and upgrades the system. If the `xbps` package was part of the update, run the full update again because XBPS uses a separate transaction for its own update. [1]

## Remove Carefully

```sh
sudo xbps-remove <package>
sudo xbps-remove -o
```

The first removes a named package. `-o` removes orphaned dependencies. Always read the transaction preview; a package may be a dependency of a component you still need.

## Reconfigure

```sh
sudo xbps-reconfigure -f <package>
```

Use this when a package's configuration hooks must be rerun, for example after selecting a locale or changing an initramfs generator. It does not install a missing package.

## Inspect Files

```sh
xbps-query -f <package>
```

This shows which files the package owns. It is useful when a command exists but you need to find its configuration, service directory or documentation.

## References

[1] [XBPS Package Manager — Void Linux Handbook](https://docs.voidlinux.org/xbps/index.html)

[2] [xbps-install(1) — Void Linux Manual Pages](https://man.voidlinux.org/xbps-install.1)

[3] [xbps-query(1) — Void Linux Manual Pages](https://man.voidlinux.org/xbps-query.1)

[4] [xbps-remove(1) — Void Linux Manual Pages](https://man.voidlinux.org/xbps-remove.1)
