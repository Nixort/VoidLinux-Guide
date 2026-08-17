# VoidLinux-Guide — Firmware and Microcode

Firmware is hardware-specific. Install it because the hardware needs it, not because a generic list says every package is required.

## Repository Choice

Some firmware is available only in `nonfree`. Enable that repository only when a required package is located there:

```sh
sudo xbps-install -S void-repo-nonfree
sudo xbps-install -S
```

The package installs repository configuration; it does not by itself install firmware. [1]

## Intel

Intel CPU microcode is provided by `intel-ucode` in `nonfree`:

```sh
sudo xbps-install -S intel-ucode
```

After installation, force configuration of the installed kernel series so that the initramfs includes the microcode. Replace `<series>` with the installed package name such as `linux6.12`, after checking the package list:

```sh
xbps-query -l | grep '^ii linux'
sudo xbps-reconfigure -f <series>
```

Reboot and inspect the kernel information:

```sh
grep microcode /proc/cpuinfo
```

## AMD

The `linux-firmware-amd` package contains AMD CPU and GPU microcode:

```sh
sudo xbps-install -S linux-firmware-amd
```

Void's firmware guide states that AMD microcode loads automatically without further configuration. Verify the affected device after reboot rather than assuming that package installation proves hardware support. [2]

## `/boot` Capacity

Old kernels remain available for rollback and can accumulate in `/boot`. Do not delete kernel files manually. Use `vkpurge list` to see removable versions and read its manual before removing one:

```sh
sudo vkpurge list
man vkpurge
```

## References

[1] [Repositories — Void Linux Handbook](https://docs.voidlinux.org/xbps/repositories/index.html)

[2] [Firmware — Void Linux Handbook](https://docs.voidlinux.org/config/firmware.html)

[3] [Kernel — Void Linux Handbook](https://docs.voidlinux.org/config/kernel.html)
