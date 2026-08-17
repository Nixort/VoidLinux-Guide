# VoidLinux-Guide — Advanced XBPS Operations

Advanced XBPS features change how future transactions behave. Use them to solve a known package-management problem, not as permanent substitutes for understanding dependencies.

## Hold a Package

A hold prevents a package from being updated during a system update:

```sh
sudo xbps-pkgdb -m hold <package>
```

Remove the hold when the reason no longer exists:

```sh
sudo xbps-pkgdb -m unhold <package>
```

A hold can leave the system with an older package than its dependency graph expects. Record the reason and review it after every update.

## Repository-Lock a Package

A repolock keeps a package tied to the repository from which it was installed. This can be useful for a package built from a customized template:

```sh
sudo xbps-pkgdb -m repolock <package>
sudo xbps-pkgdb -m repounlock <package>
```

A repolock is not a general version pin. It changes where XBPS may obtain the package, so remove it when the custom source is no longer maintained. [1]

## Ignore a Package

An `ignorepkg` entry in an `xbps.d` configuration file prevents a package from being considered for a transaction. This is an escape hatch for dependency or replacement decisions, not a routine upgrade mechanism:

```text
ignorepkg=<package>
```

The official example explains that ignoring a package can allow removing it when another package still declares it as a dependency. Before doing this, understand which package will provide the required functionality and how future updates will behave. [1]

## Downgrade

`xdowngrade` from `xtools` can install a specific cached `.xbps` package:

```sh
sudo xdowngrade /var/cache/xbps/<package-version>.xbps
```

If the package is not available in the repository index, the official XBPS workflow adds it to a local repository index and then installs from that directory:

```sh
sudo xbps-rindex -a /var/cache/xbps/<package-version>.xbps
sudo xbps-install -R /var/cache/xbps/ -f <package-version>
```

Downgrading may create dependency or security problems. Record the package version, reason, affected service and exit plan. [1]

## References

[1] [Advanced Usage — Void Linux Handbook](https://docs.voidlinux.org/xbps/advanced-usage.html)

[2] [xbps-pkgdb(1) — Void Linux Manual Pages](https://man.voidlinux.org/xbps-pkgdb.1)
