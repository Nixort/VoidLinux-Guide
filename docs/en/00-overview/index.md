# VoidLinux-Guide — Overview and Safety

This guide covers a clean Void Linux installation on **x86_64 with glibc**, followed by a controlled setup of the base system, packages, networking, services, UI, audio, security and maintenance. It is written for a single target disk and a standard live-image installation.

## Reading Model

Each stage answers five questions: what is being configured, what must already be true, what each command changes, how to verify the result, and what can go wrong. Complete one stage before continuing to the next.

| Scenario | Status |
|---|---|
| Clean installation on a separate disk | Supported. |
| UEFI or BIOS with a standard filesystem layout | Supported. |
| x86_64 + glibc | Canonical route. |
| Existing Windows/Linux installation | Separate scenario; not covered by the basic path. |
| LUKS, LVM or ZFS | Use the advanced official installation guides. |
| ARM, musl, RAID or unusual boot layouts | Separate scenario. |

The standard installer does not support LVM, LUKS or ZFS. Do not adapt a simple partitioning command to those layouts. [1]

## Safety Rules

Before partitioning, identify the target disk with `lsblk -f` and explain every existing partition. Do not use `wipefs`, `mkfs`, `fdisk` or bootloader commands until the target device is positively identified.

> **Warning:** A wrong device path can destroy another operating system or personal data. The guide does not provide a destructive disk command for blind copy-and-paste.

Do not remove `/var/service` when disabling a runit service. Remove only the symlink for the named service and verify it first with `ls -ld` and `readlink`.

Do not enable two competing network managers, two audio servers or two power managers without reading their conflict notes. A successful package installation does not prove that the resulting services are correct.

## Source Policy

Official Void Linux Handbook pages and manual pages are the source of truth for commands. Community discussions are included only when they expose a practical symptom or failure mode. See [`../reference/sources-and-validation.md`](../reference/sources-and-validation.md).

## References

[1] [Installation Guide — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/guide.html)

[2] [Partitioning Notes — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/partitions.html)
