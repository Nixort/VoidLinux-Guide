# VoidLinux-Guide — Network and Services Troubleshooting

Diagnose service supervision and network state separately. A service can be supervised while the application is unhealthy, and an interface can be up while it has no route or DNS.

## Service Checks

```sh
sudo sv status dbus
sudo sv status <network-service>
ls -ld /var/service/<network-service>
readlink /var/service/<network-service>
```

If the service fails to start, inspect its service directory, configuration and logs. Do not run the daemon manually as a permanent fix; that bypasses the service supervisor and can hide the real dependency problem.

## Network Layers

```sh
rfkill list
ip link
ip addr
ip route
getent hosts example.org
```

The order separates hardware block, link, address, route and DNS. Fix the first failed layer before changing a later one.

## NetworkManager

Before enabling NetworkManager, ensure that `dhcpcd`, `wpa_supplicant`, `wicd` or another manager is not controlling the same interface. Ensure `dbus` is active and the user belongs to `network`. [1]

A community report showed that an incorrect `rm` command can remove `/var/service` and leave NetworkManager unable to create supervision state. Inspect the path before touching it. [2]

## References

[1] [NetworkManager — Void Linux Handbook](https://docs.voidlinux.org/config/network/networkmanager.html)

[2] [Issues with starting NetworkManager on boot — r/voidlinux](https://www.reddit.com/r/voidlinux/comments/yvtyhb/issues_with_starting_networkmanager_on_boot/)
