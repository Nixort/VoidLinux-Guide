# `install.sh`

`install.sh` installs a **native Void Linux target** from an official live environment. It turns a reviewed set of choices into a visible installation plan, then requires explicit confirmation before it changes a whole disk. The script is an optional fast path; the staged manual guide remains authoritative for understanding and repairing a Void system.

> **Destructive operation.** A real run can erase one complete disk, create filesystems, write bootloader files, create encrypted volumes, and set account passwords. Start with `--dry-run`, inspect the disk report and final plan, confirm the disk basename character for character, and retain an independent backup. No script can make an incorrectly confirmed disk safe.

## What It Does—and Does Not Do

| The installer does | The installer deliberately does not do |
|---|---|
| Checks DNS and HTTPS access to the selected XBPS repository before its disk stage. | Download an ISO, bypass package signatures, or use an arbitrary mirror. |
| Inspects disks, mounts, filesystem signatures, LVM and RAID metadata before it offers a destructive route. | Operate on a partition, mounted disk, loop device, RAM disk, live-root disk, or a disk it considers too small. |
| Bootstraps Void with the documented XBPS/chroot path, configures a selected desktop profile, services, bootloader and target-side mirror override. [1] | Replace the manual installation route or support cross-architecture chroots and board-specific ARM boot firmware. |
| Creates a resumable private state file and a redacted post-install backup. | Store passwords, LUKS passphrases, QR payloads, private Secure Boot keys, or LUKS token material in state, logs, backups, or tracked files. |
| Checks TPM2/FIDO2/Secure Boot readiness and prepares a documented next-step handoff when requested. | Bind a TPM token, enroll a FIDO2 token, remove a LUKS passphrase, enroll firmware keys, sign unknown EFI binaries, or enable Secure Boot in firmware. |

## Supported Targets

The installer is native-only: the live system architecture must match the selected target. Generic `aarch64` is UEFI-only; a board-specific ARM image and boot chain remain a manual task. [1] [2]

| Target architecture | libc | XBPS target | Repository route | Boot scope |
|---|---|---|---|---|
| `x86_64` | `glibc` | `x86_64` | `/current` | UEFI or BIOS |
| `x86_64` | `musl` | `x86_64-musl` | `/current/musl` | UEFI or BIOS |
| `aarch64` | `glibc` | `aarch64` | `/current/aarch64` | Generic UEFI only |
| `aarch64` | `musl` | `aarch64-musl` | `/current/aarch64` | Generic UEFI only |

## Start Safely

Boot the appropriate official Void Linux live image, obtain this repository, and run the first plan as `root`. A dry run renders network, mirror, storage, encryption, bootstrap, package, service, bootloader, hardware-security and backup steps, but does not write a disk, mutate a package database, change a service, create installer state, or reveal/store a secret.

```sh
# chmod +x tools/install.sh
# ./tools/install.sh --dry-run
```

For a reproducible review, copy the configuration template to a private location, set the **non-secret** choices, and render it first. The distributed template is intentionally non-destructive and contains no credentials.

```sh
# install -m 600 tools/install.example.conf /root/void-install.conf
# editor /root/void-install.conf
# ./tools/install.sh --dry-run --non-interactive --config /root/void-install.conf
```

A real interactive run is started without `--dry-run`. A real non-interactive run additionally requires `CONFIRM_TOKEN=VOID_INSTALL` in its reviewed configuration. The encrypted non-interactive route rejects empty passphrase fields; use the interactive route unless you have a secure, audited secret-delivery method. Never put passwords or passphrases in a committed configuration, shell history, terminal scrollback capture, or shared file.

```sh
# ./tools/install.sh
```

## Execution Model

The script exposes its work in ordered stages. A failure stops the run before subsequent stages execute; completed real-install stages can be resumed from the private state file.

| Stage | Safety property |
|---|---|
| Preflight | Validates native target selection, supported boot path, repository route, DNS and bounded HTTPS access before disk confirmation. |
| Inspection | Reports disk identity, size, transport, signatures, filesystem tree, mounts and available LVM/RAID metadata. |
| Plan and confirmation | Shows the selected target and layout. Existing signatures require `ERASE-SIGNATURES`, followed by `YES` and the exact disk basename. |
| Provisioning | Partitions, encrypts when selected, mounts the new filesystems and records only non-secret recovery metadata. |
| Bootstrap and configuration | Uses XBPS bootstrap/chroot, configures the selected system, and installs the boot path appropriate to the target. [1] |
| Handoff | Creates a redacted target backup and, when requested, root-only TPM2/FIDO2/Secure Boot next-step notes. |

## Command-Line Interface

| Option | Purpose | Important boundary |
|---|---|---|
| `--dry-run` | Render the complete plan without mutating disks, package databases, services, firmware variables, or installer state. | It is a plan review, not a VM or hardware validation. |
| `--config FILE` | Load a reviewed shell-style configuration file. | Do not pair it with `--resume` or `--recover`. |
| `--non-interactive` | Require configuration/resume values and `CONFIRM_TOKEN=VOID_INSTALL` for a real run. | It is not a substitute for reviewing the rendered plan. |
| `--target-root DIR` | Set the staging root; default: `/mnt/voidlinux-guide`. | Use only an empty, controlled staging path. |
| `--repo URL` | Supply the official repository route instead of automatic architecture/libc derivation. | It is validated as an official Void route. |
| `--mirror URL` | Select an allow-listed official mirror base or repository URL. | A mirror must pass repository-route validation and preflight. |
| `--resume FILE` | Continue a compatible interrupted real installation from a private state file. | Encrypted targets ask again for their passphrase(s); secrets are not in state. |
| `--recover FILE` | Mount the recorded target and create a non-destructive recovery report and static-XBPS handoff. | It never partitions, installs packages, or launches a repair command. |
| `-h`, `--help` | Show the usage summary emitted by the installed script version. | Prefer this output if it differs from this document. |

## Configuration Reference

[`install.example.conf`](install.example.conf) is the complete, versioned template. Copy it outside the repository and review every value. The fields below are the primary decision points; any empty password/passphrase field is intentional.

| Area | Primary fields | Accepted or intended values |
|---|---|---|
| Target | `TARGET_DISK`, `TARGET_ARCH`, `TARGET_LIBC`, `BOOT_MODE`, `TARGET_ROOT` | Whole disk such as `/dev/sdX`; `x86_64` or `aarch64`; `glibc` or `musl`; `uefi` or `bios` subject to target restrictions. |
| Repository | `REPO_URL`, `TARGET_MIRROR_URL` | Leave `REPO_URL` empty for automatic selection. Use only an allow-listed official mirror for `TARGET_MIRROR_URL`. |
| Storage | `PARTITION_LAYOUT`, `ROOT_SIZE_GIB`, `BOOT_SIZE_GIB`, `SWAP_SIZE_GIB`, `ESP_SIZE_MIB` | `single-root`, `root-home`, `root-home-swap`, or `boot-encrypted-home`. |
| Encryption | `ENCRYPTION`, `CRYPT_CIPHER`, `CRYPT_KEY_SIZE`, mapping/LV names | `none`, `luks1-lvm`, or `luks2-separate`. `luks2-separate` is only valid with `boot-encrypted-home`. |
| Identity | `HOSTNAME_VALUE`, `TARGET_USER`, `TIMEZONE`, `LOCALE` | Values used to configure the new target; verify locale and timezone before a real run. |
| Desktop and baseline | `DESKTOP`, `DISPLAY_PROTOCOL`, `SESSION_MANAGER`, `GPU`, `NETWORK_MANAGER`, `FIREWALL`, `APPARMOR`, `ENABLE_SSH` | Selected by the interactive flow or reviewed explicitly in the template. Unsupported combinations are refused. |
| Hardware security | `TPM2_MODE`, `FIDO2_MODE`, `SECURE_BOOT_MODE` | `TPM2_MODE=off|check|clevis-tpm2`; `FIDO2_MODE=off|check`; `SECURE_BOOT_MODE=off|check|prepare`. These modes apply to the LUKS2 separate-boot profile. |
| Accounts | `GENERATE_ROOT_PROFILE`, `GENERATE_USER_PROFILE`, `SHOW_QR` | Password fields must remain out of tracked configuration; QR output is screen-only and never written to state. |

## Storage and Encryption Profiles

The profile determines the boot path, partition layout, and encryption implementation. Select the simplest profile that satisfies the threat model and recovery capability of the machine.

| Layout | Boot arrangement | Root and home arrangement | Availability |
|---|---|---|---|
| `single-root` | ESP on UEFI when required | Plain ext4, or one LUKS1/LVM volume | UEFI or BIOS |
| `root-home` | ESP on UEFI when required | Plain ext4, or LUKS1/LVM root and home LVs | UEFI or BIOS |
| `root-home-swap` | ESP on UEFI when required | Plain ext4, or LUKS1/LVM root, swap and home LVs | UEFI or BIOS |
| `boot-encrypted-home` | FAT32 ESP and plain ext4 `/boot` | Independent LUKS2 root and LUKS2 `/home`; optional plain swap | UEFI only |

`boot-encrypted-home` leaves only boot metadata, kernel, and initramfs outside encryption so the bootloader can load them without a LUKS2 unlock path. It keeps separate root and home passphrases. Void documents its standard full-disk-encryption route with LUKS1 because of GRUB compatibility constraints; this separate `/boot` profile makes the LUKS2 boundary explicit rather than claiming passwordless boot. [3]

## Network and Mirror Policy

The script performs DNS and bounded HTTPS reachability checks for the target `repodata` before any disk operation. It does not turn a reachable mirror into a trust decision: XBPS signature verification remains responsible for package authenticity. [4]

Only these official mirror hosts are accepted: `repo-default.voidlinux.org`, `repo-de.voidlinux.org`, `repo-fi.voidlinux.org`, and `repo-fr.voidlinux.org`. The selected route is checked before bootstrap, recorded through a target-side `/etc/xbps.d` override, synchronized, and verified with `xbps-query -L`, following Void’s mirror override model. [4]

## TPM2, FIDO2, and Secure Boot

These controls are intentionally **readiness and handoff paths**, not silent credential or firmware automation. Retain bootable recovery media and all LUKS passphrases before any manual follow-up.

| Mode | Installer action | Explicit non-goal |
|---|---|---|
| `TPM2_MODE=check` | Checks for TPM2 device visibility and queries fixed capabilities where available. | No TPM-bound LUKS token, no slot change, no passphrase removal. |
| `TPM2_MODE=clevis-tpm2` | Installs `clevis`, `tpm2-tools`, and `tpm2-tss`, then creates a root-only manual TPM2 handoff. | No automatic `clevis luks bind` or unlock-policy decision. |
| `FIDO2_MODE=check` | Checks HID raw device availability and records the compatibility boundary. | No FIDO2 LUKS2 token enrollment. |
| `SECURE_BOOT_MODE=check` | Checks UEFI runtime variable availability. | No firmware key creation, replacement, enrollment, or enablement. |
| `SECURE_BOOT_MODE=prepare` | Installs `sbctl`, runs `sbctl setup`, records status, and writes a signing checklist. | No `create-keys`, `enroll-keys`, unknown-EFI signing, or firmware change. |

FIDO2 and TPM2 automatic unlock require LUKS2 token metadata plus a matching initramfs unlock stack. The P1 installer therefore uses verified readiness checks and a manual handoff rather than treating a device check as a secure enrollment. `sbctl` key enrollment is likewise a high-impact firmware operation and remains an operator decision. [5] [6] [7]

## Resume and Recovery

A real installation writes a root-owned `0600` state file under `/run/voidlinux-guide-installer/`. It contains non-secret layout, device, choice, and completed-stage information. It does not contain passwords, LUKS passphrases, or QR data.

```sh
# ./tools/install.sh --resume /run/voidlinux-guide-installer/sda.state
```

The recovery route is deliberately less powerful than an installer. It validates the recorded state, mounts the known target as needed, then writes a diagnostic report, system configuration copies, package/repository manifests, and an **unexecuted** static-XBPS rescue script inside the target. Inspect the report and decide each repair manually.

```sh
# ./tools/install.sh --recover /run/voidlinux-guide-installer/sda.state
```

Void documents `xbps-static` as a recovery mechanism when the normal XBPS tooling is not usable. The generated rescue script is only a starting point: a recovery operator must review it against the actual failed system and repository state. [8]

## Post-Install Backup

On successful completion, the target receives a root-only directory at the following location.

```text
/root/voidlinux-guide-install-backup-<timestamp>/
```

The backup is a configuration handoff, not a bare-metal image. It includes a redacted installation summary; package and repository manifests; `fstab`; `crypttab`; GRUB and dracut configuration; enabled-service links; EFI file inventory; mirror overrides; checksums; and generated security handoffs. It excludes passwords, LUKS passphrases, private Secure Boot keys, token material, QR payloads, and the pre-install disk serial report.

## Verification and Deployment Boundary

Run static and dry-run checks after changing `install.sh` or its template. The command below validates shell syntax, ShellCheck findings, CLI availability, and an example P1 plan without touching a disk.

```sh
$ bash -n tools/install.sh
$ shellcheck -x tools/install.sh
$ bash tools/install.sh --help
# bash tools/install.sh --dry-run --non-interactive --config /root/void-install.conf
```

The maintained P1 validation covered syntax, ShellCheck with no warnings, Git whitespace, legacy P0 dry-run, LUKS2 separate-boot dry-run, official-mirror preflight plan, TPM2/FIDO2/Secure Boot handoff plans, resume, recovery, and negative safety cases. It did **not** claim a real hardware installation or firmware change. The following actions still require disposable native hardware or an equivalently isolated VM with a recovery medium:

| Required manual validation | Reason |
|---|---|
| Every architecture/libc/layout on a real target | Boot firmware, storage naming, and live image behavior cannot be proven by plan rendering. |
| Interrupted-stage resume and failed-boot recovery | Requires an actual target state and a controlled fault. |
| Each mirror route and target-side override | Requires a live repository transaction and fallback testing. |
| TPM2 binding, FIDO2 enrollment, and fallback passphrase boot | Changes access-control policy and must have tested recovery. |
| `sbctl` signing, key enrollment, and Secure Boot enablement | Changes firmware trust state and can prevent boot if misapplied. |

## References

[1] [Installation via chroot — Void Linux Handbook](https://docs.voidlinux.org/installation/guides/chroot.html)

[2] [ARM Devices — Void Linux Handbook](https://docs.voidlinux.org/installation/guides/arm-devices/index.html)

[3] [Full Disk Encryption — Void Linux Handbook](https://docs.voidlinux.org/installation/guides/fde.html)

[4] [Changing Mirrors — Void Linux Handbook](https://docs.voidlinux.org/xbps/repositories/mirrors/changing.html)

[5] [sbctl documentation](https://github.com/Foxboron/sbctl)

[6] [Clevis documentation](https://github.com/latchset/clevis)

[7] [systemd-cryptenroll documentation](https://www.freedesktop.org/software/systemd/man/latest/systemd-cryptenroll.html)

[8] [Static XBPS — Void Linux Handbook](https://docs.voidlinux.org/xbps/troubleshooting/static.html)
