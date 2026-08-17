# VoidLinux-Guide — Troubleshooting Stage

Troubleshooting starts with the layer that owns the symptom. Do not reinstall the entire system when a status command can identify the failing package, service, route or session variable.

## Guides

| Guide | Purpose |
|---|---|
| [Boot and Kernel](boot-and-kernel.md) | Separate bootloader, kernel, initramfs and filesystem failures. |
| [XBPS Errors](xbps-errors.md) | Classify repository, signature, shlib and transaction errors. |
| [Network and Services](network-and-services.md) | Diagnose runit, D-Bus, interfaces and manager conflicts. |
| [UI and Audio](ui-and-audio.md) | Diagnose graphical sessions, PipeWire and runtime environment. |

## Evidence Rule

Record the exact error, the command, the stage, the last known successful state and relevant versions. Do not publish credentials, private keys, Wi-Fi passwords, tokens or unredacted private network details.
