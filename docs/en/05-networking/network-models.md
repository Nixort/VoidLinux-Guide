# VoidLinux-Guide — Network Models

A network interface should have one clear owner. Most “network is broken” cases become easier when you identify which service is supposed to configure the interface and remove competing managers from the path.

## Default DHCP

The default Void installation enables `dhcpcd`. Inspect it before adding another manager:

```sh
sudo sv status dhcpcd
ip link
ip addr
ip route
```

If DHCP is sufficient, keep this simple path. Do not install NetworkManager only because a desktop tutorial for another distribution assumes it.

## Static Configuration

The Handbook describes a simple static setup through `ip` commands in `/etc/rc.local`:

```sh
ip link set dev <interface> up
ip addr add <address>/<prefix> dev <interface>
ip route add default via <gateway>
```

Use the actual interface from `ip link`, and add DNS configuration separately. Test the route before making it persistent. [1]

## NetworkManager Ownership

Before enabling NetworkManager, disable `dhcpcd`, `wpa_supplicant`, `wicd` or another service that configures the same interface. NetworkManager also requires system D-Bus. [2]

Do not disable a manager by deleting `/var/service`. Remove only the named service link after verifying it with `readlink`.

## Verify in Layers

```sh
ip link
ip addr
ip route
getent hosts example.org
```

These tests separate link state, address assignment, routing and name resolution. A working IP route does not prove that DNS works, and a successful DNS lookup does not prove that the intended interface is being used.

## References

[1] [Network — Void Linux Handbook](https://docs.voidlinux.org/config/network/index.html)

[2] [NetworkManager — Void Linux Handbook](https://docs.voidlinux.org/config/network/networkmanager.html)
