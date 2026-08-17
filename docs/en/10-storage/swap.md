# VoidLinux-Guide — Swap

Swap is disk-backed memory used under pressure and is also required for hibernation. It is not a universal substitute for sufficient RAM.

## Inspect

```sh
free -h
swapon --show
cat /proc/swaps
```

These commands distinguish configured swap from available memory. A swap partition is optional for many systems, but hibernation needs enough suitable swap for the intended memory image. Void's partitioning notes provide size guidance by RAM and hibernation scenario. [1]

## Enable an Existing Swap Entry

If the installer created a swap partition and it is present in `fstab`, verify it:

```sh
sudo swapon -a
swapon --show
```

Do not format a device to “fix” missing swap until `lsblk -f` and `/etc/fstab` show that it is actually the intended swap device.

## Verify After Reboot

```sh
swapon --show
free -h
```

## References

[1] [Partitioning Notes — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/partitions.html)
