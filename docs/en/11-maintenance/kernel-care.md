# VoidLinux-Guide — Kernel and `/boot` Care

Void keeps old kernel files for rollback. This is useful until a small `/boot` becomes full and prevents a new initramfs from being generated.

## Check Space and Versions

```sh
df -h /boot 2>/dev/null || true
uname -r
sudo vkpurge list
```

`vkpurge list` shows removable kernel versions. It does not remove kernel packages and does not list the currently booted or package-provided versions. [1]

## Remove an Old Version

Read the manual first:

```sh
man vkpurge
```

When the version is clearly removable and a known-good kernel remains, use the documented `vkpurge rm <version>` form. Never delete files directly from `/boot`; the utility runs the required kernel removal hooks.

## If `/boot` Is Full

Do not start another kernel update. Boot a known-good kernel if necessary, inspect `vkpurge list`, remove only versions that are safe to remove, and rerun the kernel configuration hooks through the official package mechanism.

## References

[1] [Kernel — Void Linux Handbook](https://docs.voidlinux.org/config/kernel.html)

[2] [vkpurge(8) — Void Linux Manual Pages](https://man.voidlinux.org/vkpurge.8)
