# VoidLinux-Guide

**VoidLinux-Guide** is an English-first, staged guide to installing, configuring, maintaining, and recovering Void Linux. Each guide explains the command, the component it changes, a verification step, and a safe failure boundary.

> **Scope.** The manual route covers standard Void Linux installation and post-install setup. It uses Void conventions—XBPS and runit—and does not silently substitute systemd, Debian, Arch, or another distribution’s workflow.

## Start Here

| Goal | Read or run |
|---|---|
| Install and configure manually | [`docs/en/00-overview`](docs/en/00-overview) → [`docs/en/01-installation`](docs/en/01-installation) |
| Understand package management | [`docs/en/04-packages`](docs/en/04-packages) |
| Set up a desktop, networking, services, audio, storage, or security | Use the stage map below. |
| Review the optional native installer | [`tools/README.md`](tools/README.md), then `./tools/install.sh --dry-run` from an official live environment. |
| Contribute a guide or translation | [`CONTRIBUTING.md`](CONTRIBUTING.md) and [`docs/README.md`](docs/README.md). |

## Guide Map

| Stage | Topic |
|---|---|
| [`00-overview`](docs/en/00-overview) | Scope, safety model, and reading order. |
| [`01-installation`](docs/en/01-installation) | ISO, boot mode, partitioning, and `void-installer`. |
| [`02-setup`](docs/en/02-setup) | First boot, users, locale, time, firmware, and first update. |
| [`03-base-system`](docs/en/03-base-system) | Kernel, shell, environment, and system inspection. |
| [`04-packages`](docs/en/04-packages) | XBPS concepts, commands, repositories, and recovery. |
| [`05-networking`](docs/en/05-networking) | DHCP, Wi-Fi, NetworkManager, DNS, and diagnostics. |
| [`06-services`](docs/en/06-services) | runit, service lifecycle, logs, and per-user services. |
| [`07-ui`](docs/en/07-ui) | Xorg, Wayland, sessions, display managers, and desktops. |
| [`08-audio`](docs/en/08-audio) | ALSA, PipeWire, WirePlumber, and debugging. |
| [`09-security`](docs/en/09-security) | Permissions, firewall, AppArmor, and remote access. |
| [`10-storage`](docs/en/10-storage) | Mounts, `fstab`, swap, SSDs, and backup precautions. |
| [`11-maintenance`](docs/en/11-maintenance) | Updates, kernel care, logs, and recurring checks. |
| [`12-troubleshooting`](docs/en/12-troubleshooting) | Boot, XBPS, networking, UI, and audio recovery playbooks. |
| [`reference`](docs/en/reference) | Command matrix, glossary, and source validation. |

## Optional Installer

[`tools/install.sh`](tools/install.sh) is a reviewed, native-target installer—not a replacement for understanding the manual route. It requires a dry-run review, performs network and disk safety checks before destructive work, supports resumable installation and non-destructive recovery, and keeps passwords/passphrases out of tracked files and state. Its complete usage, configuration reference, encryption profile matrix, hardware-security limits, recovery process, and validation boundary are in [`tools/README.md`](tools/README.md).

## Languages

`docs/en/` is canonical and maintained in English. The directories `docs/ru`, `docs/de`, `docs/es`, `docs/fr`, `docs/ja`, and `docs/zh` are reserved for community translations. A translation must preserve file names, commands, paths, warnings, verification steps, and source links.

## Evidence Standard

Official Void Linux Handbook pages and Void manual pages are normative for commands. Community discussions may document symptoms or failure modes, but do not replace an official source. High-risk commands are introduced with their impact and a verification step.

## References

[1] [The Void Linux Handbook](https://docs.voidlinux.org/)
