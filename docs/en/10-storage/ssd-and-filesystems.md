# VoidLinux-Guide — SSD and Filesystems

Storage optimization should be conservative. A filesystem that is mounted and backed up is more valuable than an aggressive tuning change that cannot be explained or rolled back.

## Inspect the Storage Layer

```sh
lsblk -f
findmnt -D
df -h
```

Identify the filesystem, mount options and free space before changing mount flags. The intended filesystem and hardware determine which options are valid.

## Separate `/boot` Warning

Void does not remove old kernels automatically. A small separate `/boot` can fill over time, causing failed updates or incomplete initramfs generation. Check it before a kernel update and use `vkpurge` for removable versions. [1]

```sh
df -h /boot 2>/dev/null || true
sudo vkpurge list
```

## Avoid Generic Tuning

Do not copy `discard`, scheduler, compression, `noatime` or filesystem-specific options from another machine without verifying the device, filesystem and current kernel behavior. Measure a real problem first and keep a tested rollback path.

## References

[1] [Kernel — Void Linux Handbook](https://docs.voidlinux.org/config/kernel.html)

[2] [Solid State Drives — Void Linux Handbook](https://docs.voidlinux.org/config/ssd.html)
