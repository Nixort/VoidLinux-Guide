# VoidLinux-Guide — Prepare the Live Image

This guide prepares a Void Linux live environment for the standard installation path. It does not install packages into the target disk yet.

## Choose the Image

Use an official Void Linux download and follow its current verification instructions. Match the image to the target architecture and libc. The canonical route in this repository is `x86_64` with glibc.

Do not use a tutorial that silently substitutes an image from another release, architecture or libc. A live image can boot successfully and still be the wrong source for the intended installation.

## Write the Installation Media

Use a trusted image-writing tool appropriate for your current operating system. Select the correct USB device and verify the tool's final target before writing. Do not copy a block-device command from a different operating system without checking its device naming rules.

After writing the image, reboot and select the USB device from the firmware boot menu. Keep the target disk and the installation USB physically distinguishable.

## Confirm the Boot Mode

Before opening the installer, determine whether the live environment was booted through UEFI or BIOS. The partition table and bootloader choice depend on this decision. Void recommends GPT with an EFI System Partition for UEFI and MBR for BIOS. [1]

If the machine boots in the wrong mode, reboot and choose the correct firmware entry rather than attempting to repair the layout later.

## Completion Check

The live environment is ready when:

- The image matches `x86_64` and glibc.
- The target disk is identified independently from the USB device.
- The boot mode is known.
- A backup exists for any disk that contains data.
- The next step can run `void-installer` as `root`.

## References

[1] [Installation Guide — Void Linux Handbook](https://docs.voidlinux.org/installation/live-images/guide.html)

[2] [Void Linux Downloads](https://voidlinux.org/download/)
