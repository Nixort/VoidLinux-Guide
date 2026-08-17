# VoidLinux-Guide — Mounts and `fstab`

A mount connects a filesystem to a directory. `/etc/fstab` describes mounts that should be recreated at boot. A wrong entry can delay or prevent boot, so inspect first and change one entry at a time.

## Inspect

```sh
lsblk -f
findmnt
cat /etc/fstab
```

Prefer stable identifiers such as UUID or filesystem labels over changing device names. Confirm the filesystem type and target directory before writing an entry.

## Test a New Entry

After editing `/etc/fstab`, test the entry while you still have a working session:

```sh
sudo mount -a
findmnt
```

`mount -a` attempts all applicable entries. If it reports an error, fix or remove the new entry before rebooting. Do not assume that a successful editor save means the syntax or device is valid.

## Separate `/home` or `/boot`

A separate `/home` can help preserve user data during a reinstall, but it does not replace backups. A separate `/boot` must have enough capacity for multiple kernels; Void retains old kernels for rollback. [1]

## References

[1] [Partitioning Notes — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/partitions.html)

[2] [fstab(5) — Void Linux Manual Pages](https://man.voidlinux.org/fstab.5)
