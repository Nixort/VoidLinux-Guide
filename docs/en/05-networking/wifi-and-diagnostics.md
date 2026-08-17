# VoidLinux-Guide — Wi-Fi and Network Diagnostics

Diagnose wireless networking in layers. Start with hardware and interface state before changing packages or services.

## Check Radio State

```sh
rfkill list
ip link
```

`rfkill` reports software and hardware blocks. `ip link` shows the actual interface name; do not assume it is `wlan0` or `eth0`, because predictable naming is common.

## Check Address and Route

```sh
ip addr
ip route
```

A wireless interface may be present but have no address. It may have an address but no default route. Treat those as different failures.

## Check DNS Separately

```sh
getent hosts example.org
cat /etc/resolv.conf
```

If an IP address works but `getent` fails, inspect DNS ownership rather than reinstalling the Wi-Fi driver.

## Choose a Wireless Tool

Void documents `wpa_supplicant`, `iwd`, NetworkManager and ConnMan. Select one management model. Two tools configuring the same wireless interface can fight over state and create intermittent symptoms. [1]

## Evidence for a Report

Collect:

```sh
rfkill list
ip link
ip addr
ip route
sv status dbus
sv status <network-service>
```

Remove passwords, SSIDs and public IP addresses before publishing the output.

## References

[1] [Network — Void Linux Handbook](https://docs.voidlinux.org/config/network/index.html)

[2] [NetworkManager — Void Linux Handbook](https://docs.voidlinux.org/config/network/networkmanager.html)
