# VoidLinux-Guide — Partitioning

Partitioning is the point of no return in a clean installation. This guide explains the layout decisions; the installer still performs the actual partitioning after the target disk is verified.

## UEFI Layout

Use GPT. Create an EFI System Partition with a `vfat` filesystem and mount it at `/boot/efi`. Void documents 200 MB to 1 GB as a reasonable ESP range. The remaining space can be used for a root filesystem, with swap optional. [1]

## BIOS Layout

Use MBR for the simple BIOS route. If BIOS must boot from GPT, create a 1 MB BIOS boot partition at the beginning of the disk with no filesystem. GRUB uses this space to boot. [1]

## Root and Home

A single root filesystem is valid for the basic route. A separate `/home` can simplify reinstalling the operating system while retaining user data, but it does not replace backups and adds another mount that must be maintained.

## Swap

Swap is not strictly required. It is useful with low RAM and required for hibernation. Void's partitioning notes give size recommendations based on RAM and hibernation; do not apply a fixed swap size to every machine. [1]

## Verification Checklist

Before writing the partition table, verify:

| Question | Required answer |
|---|---|
| Is the disk the intended target? | Yes, confirmed from `lsblk -f` and physical/firmware context. |
| Is the boot mode known? | UEFI or BIOS, not an assumption. |
| Does the table match the boot mode? | GPT for UEFI; MBR for simple BIOS. |
| Is the ESP preserved if it is shared? | Only when the separate dual-boot scenario is intentionally handled. |
| Are format flags correct? | Only the intended new partitions are formatted. |

> **Warning:** Do not use `wipefs`, `mkfs` or a raw disk-writing command unless you can identify the target device and have a backup. Dual-boot and existing-data installations belong to a separate guide.

## References

[1] [Partitioning Notes — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/partitions.html)
