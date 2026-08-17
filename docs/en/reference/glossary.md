# VoidLinux-Guide — Glossary

| Term | Meaning |
|---|---|
| XBPS | The X Binary Package System, Void's package-management system. |
| Repository index | Signed metadata describing packages available from a repository. |
| runit | The init and service-supervision framework used by Void. |
| `runsvdir` | A directory of service links supervised by runit. |
| Service directory | A directory containing the foreground `run` program and optional service files. |
| `/var/service` | The active service-link directory for the running default runsvdir. |
| D-Bus system bus | A system-wide IPC bus used by services. |
| D-Bus session bus | A per-user IPC bus used by desktop applications. |
| `XDG_RUNTIME_DIR` | A per-user runtime directory used by Wayland, PipeWire and other session software. |
| glibc | The GNU C library. The canonical route in this guide uses glibc. |
| musl | An alternative C library supported by Void but with different locale and package assumptions. |
| initramfs | The temporary root filesystem loaded before the real root filesystem during boot. |
| ESP | EFI System Partition, normally a `vfat` filesystem mounted at `/boot/efi` for UEFI. |
| WirePlumber | The PipeWire session manager used by the current Void PipeWire package. |
| seat manager | Software that grants graphical sessions controlled access to display and input devices. |
