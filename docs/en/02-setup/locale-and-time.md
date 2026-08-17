# VoidLinux-Guide — Locale and Time

Locale controls language and formatting. Timezone selects the offset used to display time; it does not set the clock itself. These settings should be correct before diagnosing repository or TLS errors.

## Check the Current Locale

```sh
locale
locale -a
```

Void documents system locale configuration for glibc. musl does not support setting a system locale in the same way, although applications can still select a language. [1]

## Enable and Select a Locale

Enable the desired locale in `/etc/default/libc-locales`, then reconfigure the package:

```sh
sudo $EDITOR /etc/default/libc-locales
sudo xbps-reconfigure -f glibc-locales
```

Set the default language in `/etc/locale.conf`:

```sh
printf '%s\n' 'LANG=en_US.UTF-8' | sudo tee /etc/locale.conf
```

Replace the example with a locale that appears in `locale -a`. Log in again and verify with `locale`.

## Set the Timezone

Link the timezone database entry to `/etc/localtime`:

```sh
sudo ln -sf /usr/share/zoneinfo/<Region>/<City> /etc/localtime
date
```

If `/etc/rc.conf` defines `TIMEZONE`, remove or comment it so that it does not override `/etc/localtime` at boot. [2]

## Synchronize the Clock

Choose one NTP implementation, install it and enable its documented service. Void provides NTP, OpenNTPD, Chrony and ntpd-rs; this guide does not claim that one is universally best.

```sh
sudo xbps-install -S chrony
sudo ln -s /etc/sv/chronyd /var/service/
sudo sv status chronyd
```

Check the service according to the package's documentation. A timezone can be correct while the clock is still wrong, so verify both `date` and the NTP service.

## Dual-Boot Note

Void stores the hardware clock as UTC by default. Windows commonly uses localtime. Do not change `HARDWARECLOCK` in a dual-boot system without following the dedicated date/time guidance for both operating systems. [2]

## References

[1] [Locales and Translations — Void Linux Handbook](https://docs.voidlinux.org/config/locales.html)

[2] [Date and Time — Void Linux Handbook](https://docs.voidlinux.org/config/date-time.html)
