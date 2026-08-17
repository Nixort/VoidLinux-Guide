# VoidLinux-Guide — Install with `void-installer`

This guide describes the standard clean-disk installation. It assumes that the live image is already booted and that the target disk contains no data that must be preserved.

## Start

The live image provides a root login with password `voidlinux`. Start the installer:

```sh
void-installer
```

The installer presents a sequence of screens. Review each value before continuing.

| Screen | What it controls | Verification |
|---|---|---|
| Keyboard | Console keymap. | Test representative keys. |
| Network | Interface, DHCP or static settings, and Wi-Fi credentials. | The live environment can reach the selected source. |
| Source | `Local` packages from the image or `Network` packages from repositories. | Choose intentionally; the Xfce image has a documented `Local` requirement. [1] |
| Hostname | Machine name. | Use lowercase without spaces. |
| Locale | glibc locale selection. | Choose an enabled locale or keep the default intentionally. |
| Timezone | System timezone. | Confirm the region and city. |
| Root password | Administrative recovery password. | Store it securely. |
| User account | Ordinary login and groups. | Confirm the user and `wheel` membership. |
| Bootloader | Disk receiving the bootloader. | Match the target disk and boot mode. |
| Partition | Partition table and partition layout. | Re-check the disk against `lsblk -f`. |
| Filesystems | Filesystem creation and mount points. | Confirm `/` and `/boot/efi` where applicable. |

## Partitioning Decision

For UEFI, use GPT and an EFI System Partition formatted as `vfat` and mounted at `/boot/efi`. Void's notes describe a reasonable ESP size as 200 MB to 1 GB. For BIOS, MBR is the recommended simple choice. BIOS booting from GPT requires a special 1 MB BIOS boot partition without a filesystem. [2]

## Review Before Install

Use the installer's review screen. Confirm the target disk, partition table, filesystem creation flags, mount points, hostname, user and bootloader. If any value is unclear, cancel before installation and return to the partitioning notes.

Selecting `Install` creates the filesystems, installs the base packages, generates an initramfs and installs GRUB when selected. [1]

## First Reboot

After a successful installation, reboot, remove the USB, and log in to the new system. Do not begin advanced configuration until the installed disk, not the live USB, is the current root filesystem.

```sh
findmnt /
uname -m
```

Expected result: `/` is mounted from the installed target disk and the architecture is `x86_64`.

## References

[1] [Installation Guide — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/guide.html)

[2] [Partitioning Notes — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/partitions.html)
