# Documentation Structure

VoidLinux-Guide uses a staged documentation model. The English documentation is the canonical version and is maintained by the project first. Other language directories are reserved for community translations and must not contain partial machine translations in the canonical repository.

## Languages

| Directory | Status | Rule |
|---|---|---|
| `docs/en/` | Canonical | All current guides are written and reviewed in English. |
| `docs/ru/` | Reserved | Community translation target; keep the same filenames and headings as `docs/en/`. |
| `docs/de/` | Reserved | Community translation target. |
| `docs/es/` | Reserved | Community translation target. |
| `docs/fr/` | Reserved | Community translation target. |
| `docs/ja/` | Reserved | Community translation target. |
| `docs/zh/` | Reserved | Community translation target. |

A translation must preserve command blocks, file paths, package names, warnings, source links and verification steps. Translators may adapt prose for natural language, but must not silently change commands or expected output.

## Stages

| Stage | Directory | Purpose |
|---|---|---|
| 00 | `00-overview/` | Scope, assumptions, safety model and reading path. |
| 01 | `01-installation/` | ISO, boot mode, partitioning and the standard installer. |
| 02 | `02-setup/` | First boot, users, sudo, locale, timezone, firmware and initial update. |
| 03 | `03-base-system/` | System identity, kernel, shell, environment and essential diagnostics. |
| 04 | `04-packages/` | XBPS concepts, commands, repositories, package lifecycle and recovery. |
| 05 | `05-networking/` | DHCP, Wi-Fi, NetworkManager, DNS and network diagnostics. |
| 06 | `06-services/` | runit concepts, service lifecycle, logs and service authoring boundaries. |
| 07 | `07-ui/` | Xorg, Wayland, session management, display managers and desktop environments. |
| 08 | `08-audio/` | ALSA, PipeWire, WirePlumber, PulseAudio compatibility and troubleshooting. |
| 09 | `09-security/` | Firewall, permissions, updates, AppArmor and safe remote administration. |
| 10 | `10-storage/` | Filesystems, mounts, fstab, swap, disks and backup precautions. |
| 11 | `11-maintenance/` | Kernel cleanup, updates, old processes, logs and recurring checks. |
| 12 | `12-troubleshooting/` | Symptom-based diagnosis and recovery playbooks. |
| Reference | `reference/` | Command references, terminology, checklists and source matrix. |

Each guide should have a narrow purpose, prerequisites, commands, explanation of what each command does, expected result, verification and limitations. A guide should not assume that the reader understands systemd, Arch, Debian or another distribution's conventions.
