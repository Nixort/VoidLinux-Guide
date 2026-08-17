# VoidLinux-Guide — Sources and Validation

Official Void Linux Handbook pages and Void manual pages are normative for commands. Community posts and articles are used to identify symptoms and failure modes; they do not override official instructions.

## Stage Matrix

| Stage | Guides | Official evidence | Community evidence |
|---|---|---|---|
| Installation | ISO, installer, partitioning | [Installation Guide][1], [Partitioning Notes][2] | Dual-boot device and bootloader confusion. [3] |
| Setup | First boot, users, locale/time, firmware | [XBPS][4], [Users][5], [Locales][6], [Date and Time][7], [Firmware][8] | Time and repository errors are treated as symptoms, not fixes. |
| Base System | Inspection, kernel lifecycle | [Kernel][9], [vkpurge(8)][10] | Old `/boot` kernels can make upgrades fail. |
| Packages | XBPS concepts, commands, advanced, recovery | [Repositories][11], [Advanced Usage][12], [Common Issues][13] | Community evidence is not used as package authority. |
| Networking | Models, NetworkManager, Wi-Fi | [Network][14], [NetworkManager][15] | Wrong `rm` syntax can remove `/var/service`; missing D-Bus can prevent NetworkManager startup. [16] |
| Services | runit, logging, user services | [Services][17], [Logging][18], [Per-User Services][19] | User services may not inherit graphical/D-Bus environment. [20] |
| UI | Architecture, Xorg, Wayland, display manager | [Graphical Session][21], [Xorg][22], [Wayland][23], [Session Management][24] | Community reports are used only for symptoms. |
| Audio | Model, PipeWire, troubleshooting | [PipeWire][25], [Session Management][24] | PipeWire user-service environment confusion. [20] |
| Security | Baseline, firewall, AppArmor | [Firewalls][26], [AppArmor][27], [Users][5] | Remote-access warnings are operational safeguards. |
| Storage | Mounts, swap, SSD, backups | [Partitioning][2], [Kernel][9], [fstab(5)][28] | Existing-data and dual-boot changes remain outside the simple path. |
| Maintenance | Updates, kernels, health checks | [XBPS][4], [Kernel][9], [Common Issues][13] | No community command is used without primary verification. |
| Troubleshooting | Boot, XBPS, network, UI/audio | Relevant stage sources above | Symptoms link back to the corresponding community reports. |

## Contribution Validation

A new command belongs in the canonical English tree only when its official source is checked, its prerequisite state is documented, its expected result is shown, and its failure or rollback boundary is clear. A Reddit or article reference must be labelled as community evidence and linked to a primary source before it becomes a recommendation.

## References

[1]: https://docs.voidlinux.org/installation/live-images/guide.html "Installation Guide"
[2]: https://docs.voidlinux.org/installation/live-images/partitions.html "Partitioning Notes"
[3]: https://www.reddit.com/r/voidlinux/comments/1iysnhd/void_linux_windows_10_dual_boot_installing_issue/ "Dual-boot issue"
[4]: https://docs.voidlinux.org/xbps/index.html "XBPS Package Manager"
[5]: https://docs.voidlinux.org/config/users-and-groups.html "Users and Groups"
[6]: https://docs.voidlinux.org/config/locales.html "Locales and Translations"
[7]: https://docs.voidlinux.org/config/date-time.html "Date and Time"
[8]: https://docs.voidlinux.org/config/firmware.html "Firmware"
[9]: https://docs.voidlinux.org/config/kernel.html "Kernel"
[10]: https://man.voidlinux.org/vkpurge.8 "vkpurge(8)"
[11]: https://docs.voidlinux.org/xbps/repositories/index.html "Repositories"
[12]: https://docs.voidlinux.org/xbps/advanced-usage.html "Advanced Usage"
[13]: https://docs.voidlinux.org/xbps/troubleshooting/common-issues.html "Common Issues"
[14]: https://docs.voidlinux.org/config/network/index.html "Network"
[15]: https://docs.voidlinux.org/config/network/networkmanager.html "NetworkManager"
[16]: https://www.reddit.com/r/voidlinux/comments/yvtyhb/issues_with_starting_networkmanager_on_boot/ "NetworkManager boot issue"
[17]: https://docs.voidlinux.org/config/services/index.html "Services and Daemons"
[18]: https://docs.voidlinux.org/config/services/logging.html "Logging"
[19]: https://docs.voidlinux.org/config/services/user-services.html "Per-User Services"
[20]: https://www.reddit.com/r/voidlinux/comments/141ezlm/getting_pipewire_to_work_for_you_the_kiss_guide/ "PipeWire community guide"
[21]: https://docs.voidlinux.org/config/graphical-session/index.html "Graphical Session"
[22]: https://docs.voidlinux.org/config/graphical-session/xorg.html "Xorg"
[23]: https://docs.voidlinux.org/config/graphical-session/wayland.html "Wayland"
[24]: https://docs.voidlinux.org/config/session-management.html "Session and Seat Management"
[25]: https://docs.voidlinux.org/config/media/pipewire.html "PipeWire"
[26]: https://docs.voidlinux.org/config/network/firewalls.html "Firewalls"
[27]: https://docs.voidlinux.org/config/security/apparmor.html "AppArmor"
[28]: https://man.voidlinux.org/fstab.5 "fstab(5)"
