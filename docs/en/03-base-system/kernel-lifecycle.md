# VoidLinux-Guide — Kernel Lifecycle

Void provides several kernel series. The `linux` meta-package normally depends on a current series selected by the distribution, while `linux-lts` and `linux-mainline` are separate choices with different stability trade-offs.

## Inspect the Kernel

```sh
uname -r
xbps-query -l | grep '^ii linux'
```

`uname -r` reports the running kernel. The package query shows installed kernel packages. These are different facts: an installed kernel is not necessarily the kernel currently booted.

## Kernel Headers and DKMS

If a package uses DKMS modules, install headers for the matching kernel series and reconfigure the kernel package after installation. Do not install arbitrary headers based only on the newest repository result.

```sh
sudo xbps-install -S <kernel-series>-headers
sudo xbps-reconfigure -f <kernel-series>
```

Check `/var/lib/dkms/` when a DKMS build fails. The kernel guide documents kernel hooks and the initramfs regeneration path. [1]

## Old Kernels

Old kernels are retained for rollback. A separate `/boot` can fill over time and cause incomplete initramfs generation. List removable versions:

```sh
sudo vkpurge list
```

Read the manual and keep a known-good boot option before removing anything:

```sh
man vkpurge
```

Never delete kernel files directly from `/boot`; `vkpurge` runs the relevant removal hooks. [1]

## Verify a Kernel Update

After an update that changes the kernel or initramfs, reboot deliberately and verify:

```sh
uname -r
df -h /boot 2>/dev/null || true
```

If a new kernel fails, select the previous kernel from the bootloader and inspect the update, `/boot` capacity and kernel hooks before repeating it.

## References

[1] [Kernel — Void Linux Handbook](https://docs.voidlinux.org/config/kernel.html)

[2] [vkpurge(8) — Void Linux Manual Pages](https://man.voidlinux.org/vkpurge.8)
