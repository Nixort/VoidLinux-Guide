# VoidLinux-Guide — How XBPS Works

XBPS separates repository metadata, package transactions and package configuration. Understanding those layers makes errors easier to classify.

## Repositories and Indexes

A repository contains package files and signed metadata such as `<arch>-repodata`. The main glibc repository is under `/current`; musl and other architectures use different paths. Remote repositories must be signed. [1]

`xbps-install -S` synchronizes repository indexes. It does not mean “install everything” and it does not update installed packages by itself. `xbps-install -u` asks XBPS to upgrade installed packages using the available indexes. `xbps-install -Su` combines both operations.

## Packages and Dependencies

A package declares dependencies and shared-library requirements. XBPS builds a transaction that may install, update, replace or remove packages to satisfy the requested state. The transaction preview is part of the safety check: read it before accepting.

A package can be installed explicitly or pulled in as a dependency. Removing a package with `xbps-remove -o` can remove orphaned dependencies, so inspect the proposed list before confirming.

## Signatures

Remote repository indexes and packages are signed. If XBPS asks to import a changed Void RSA key, compare the displayed fingerprint with the fingerprints in the official Void repositories before accepting it. [2]

## Configuration Hooks

`xbps-reconfigure` runs configuration steps for installed packages. It is used after changes that require regeneration, such as kernel or locale configuration. It does not replace the package installation transaction.

## Package Ownership

Use `xbps-query -f <package>` to see the files owned by an installed package. This is safer than guessing which package provides a command:

```sh
xbps-query -f <package>
```

The `xtools` package provides `xlocate`, which searches a cached file index:

```sh
sudo xbps-install -S xtools
xlocate <filename>
```

## References

[1] [Repositories — Void Linux Handbook](https://docs.voidlinux.org/xbps/repositories/index.html)

[2] [XBPS Common Issues — Void Linux Handbook](https://docs.voidlinux.org/xbps/troubleshooting/common-issues.html)
