# VoidLinux-Guide — Installation Stage

The installation stage produces a bootable base Void Linux system. It intentionally uses the standard `void-installer` route and links advanced disk layouts to the official Handbook.

## Guides

| Guide | Purpose |
|---|---|
| [Prepare the Live Image](prepare-live-image.md) | Choose an image, prepare media and confirm the boot mode. |
| [Install with `void-installer`](void-installer.md) | Complete the supported clean-disk installation. |
| [Partitioning Notes](partitioning.md) | Understand UEFI, BIOS, ESP, root and swap before writing a disk. |

## Completion Criteria

The system boots from the installed disk, the ordinary user can log in, the root password is known, the network can be configured, and the next stage can run `xbps-install -Su`.
