# VoidLinux-Guide — NetworkManager

NetworkManager is useful for desktop Ethernet, Wi-Fi and mobile broadband. It must be the sole manager of the interfaces it controls.

## Install and Inspect

```sh
sudo xbps-install -S NetworkManager
sudo sv status dbus
sudo sv status dhcpcd
```

The package provides `nmcli` and text-oriented tools. System D-Bus must be enabled and running before NetworkManager can start. [1]

## Switch from `dhcpcd`

Perform this locally if possible; changing the network manager may interrupt a remote session.

```sh
ls -ld /var/service/dhcpcd
readlink /var/service/dhcpcd
sudo sv down dhcpcd
sudo rm /var/service/dhcpcd
```

The final command removes only the `dhcpcd` service link. Never use a path that removes `/var/service` itself.

Enable D-Bus and NetworkManager:

```sh
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/NetworkManager /var/service/
sudo sv status dbus
sudo sv status NetworkManager
```

If a link already exists, inspect it instead of creating a duplicate.

## User Access

NetworkManager users must belong to the `network` group:

```sh
sudo usermod -aG network <username>
```

Log out and in, then check:

```sh
groups
nmcli general status
nmcli device status
```

## Common Failure

If NetworkManager only starts when run manually, inspect the D-Bus service and runit status first. A community report showed the same symptom after service-link mistakes; the official guide confirms the D-Bus dependency. [1] [2]

## References

[1] [NetworkManager — Void Linux Handbook](https://docs.voidlinux.org/config/network/networkmanager.html)

[2] [Issues with starting NetworkManager on boot — r/voidlinux](https://www.reddit.com/r/voidlinux/comments/yvtyhb/issues_with_starting_networkmanager_on_boot/)
