# VoidLinux-Guide — Boot and Kernel Troubleshooting

Separate firmware/bootloader failure from kernel, initramfs and root-filesystem failure. The repair path depends on which layer fails.

## Symptom Classification

| Symptom | First question |
|---|---|
| Firmware cannot find an entry | Is the machine booting UEFI or BIOS, and is the expected ESP/bootloader present? |
| Bootloader appears but no kernel starts | Is the selected kernel and initramfs present and is `/boot` full? |
| Kernel starts but cannot mount root | Does the initramfs contain the required storage/filesystem support? |
| System boots but networking is absent | Is the network manager service running and is the interface configured? |
| Only the newest kernel fails | Can a known-good older kernel boot? |

## Safe First Steps

If the bootloader offers an older known-good kernel, select it. Once booted:

```sh
uname -r
df -h /boot 2>/dev/null || true
sudo vkpurge list
```

Do not delete the currently running kernel. Use the official kernel and chroot guides for initramfs or bootloader repair rather than copying a generic GRUB recovery sequence.

## Evidence

Record the boot mode, target partition layout, running kernel, last successful update and any `/boot` capacity error. Keep console access available when changing boot entries.

## References

[1] [Kernel — Void Linux Handbook](https://docs.voidlinux.org/config/kernel.html)

[2] [Installation via chroot — Void Linux Handbook](https://docs.voidlinux.org/installation/guides/chroot.html)
