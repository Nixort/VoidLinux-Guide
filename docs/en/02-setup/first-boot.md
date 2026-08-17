# VoidLinux-Guide — First Boot

The first boot establishes a known package and kernel baseline. Void is a rolling-release system, so the installed image may not contain the current repository state.

## Update the Repository Index and System

The normal full update is:

```sh
sudo xbps-install -Su
```

`xbps-install` is the transaction tool. `-S` synchronizes repository indexes; `-u` upgrades installed packages. Together, `-Su` asks XBPS to refresh metadata and apply available upgrades.

Void requires a separate transaction when the `xbps` package itself is updated. Run the command a second time if the first transaction updated XBPS:

```sh
sudo xbps-install -Su
```

Do not interrupt the transaction. Read any removal or replacement list before accepting it.

## Verify the Baseline

Run the update command again and record the kernel and architecture:

```sh
sudo xbps-install -Su
uname -r
uname -m
```

The expected architecture for this route is `x86_64`. The update should complete without an unresolved dependency or repository error.

## Why This Step Comes First

A stale repository index can make later package searches misleading. A partially updated system can also produce failures that look like UI, networking or audio problems. Establishing the update baseline first narrows later diagnosis.

## If It Fails

For an installation or synchronization error, refresh the index explicitly:

```sh
sudo xbps-install -S
```

If the message mentions incorrect time, check `date` and the timezone guide. If it reports `Not Found`, inspect the repository path, architecture and libc instead of changing random mirror URLs. [1]

## References

[1] [XBPS Common Issues — Void Linux Handbook](https://docs.voidlinux.org/xbps/troubleshooting/common-issues.html)

[2] [XBPS Package Manager — Void Linux Handbook](https://docs.voidlinux.org/xbps/index.html)
