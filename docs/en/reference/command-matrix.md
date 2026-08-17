# VoidLinux-Guide — Command Matrix

Use the tool that owns the state you intend to change. Similar-looking commands from another distribution may have different semantics.

| Command | State owned | Typical use | Verify with |
|---|---|---|---|
| `xbps-install -S` | Repository indexes | Refresh package metadata. | Repeat search or update. |
| `xbps-install -Su` | Installed package set | Upgrade the system. | Run again; inspect `xcheckrestart`. |
| `xbps-query -Rs` | Package search | Search remote repositories. | Inspect package metadata. |
| `xbps-query -f` | Package ownership | Find files provided by a package. | Inspect the listed path. |
| `xbps-remove` | Installed package set | Remove a package. | Read transaction and query package state. |
| `xbps-reconfigure -f` | Package hooks | Regenerate locale/initramfs/configuration. | Check generated state or reboot. |
| `xbps-pkgdb -m hold` | Update policy | Hold one package. | Record the hold and inspect package state. |
| `sv up/down/restart/status` | runit service state | Control a service. | `sv status`. |
| `ln -s /etc/sv/... /var/service/` | Service enablement | Enable a service at boot. | `readlink /var/service/<service>`. |
| `ip link` | Interface link state | Identify names and up/down state. | `ip addr`. |
| `ip route` | Kernel routing table | Check default route. | Route and reachability test. |
| `rfkill list` | Radio block state | Check wireless hardware/software block. | Recheck after unblock. |
| `ss -tulpn` | Listening sockets | Review network exposure. | Identify owner and intended service. |
| `mount -a` | Current mount state | Test `fstab` entries. | `findmnt`. |
| `vkpurge list` | Removable kernel files | List old kernels. | Keep current and known-good kernel. |
| `wpctl status` | PipeWire graph/session | Check WirePlumber and devices. | `pactl info` if Pulse interface is enabled. |
| `uname -r` | Running kernel | Confirm the booted kernel. | Compare with installed packages. |
