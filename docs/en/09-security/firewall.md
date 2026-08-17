# VoidLinux-Guide — Firewall

Choose one firewall stack and define the policy from the services the machine actually needs. This guide does not provide a universal allowlist because an SSH server, workstation and router need different rules.

## Choose a Stack

| Stack | Rules file | Boot integration |
|---|---|---|
| `iptables` | `/etc/iptables/iptables.rules` and `/etc/iptables/ip6tables.rules` | `runit-iptables` |
| `nftables` | `/etc/nftables.conf` | `runit-nftables` |

Void documents `nftables` as replacing the older xtables family. Do not maintain two independent policies without understanding the resulting packet path. [1]

## Inspect Before Rules

```sh
ss -tulpn
ip addr
ip route
```

Write down the services that must remain reachable. If connected through SSH, keep console access or a tested rollback plan before applying a new ruleset.

## iptables Persistence

Create and test both IPv4 and IPv6 rules files, then install the runit integration:

```sh
sudo xbps-install -S runit-iptables
sudo iptables -L
sudo ip6tables -L
```

The package restores the rules at boot. Verify after reboot rather than assuming installation succeeded.

## nftables Persistence

Create `/etc/nftables.conf` using the current nftables documentation, install the integration and inspect the active ruleset:

```sh
sudo xbps-install -S nftables runit-nftables
sudo sv up nftables
sudo nft list ruleset
```

## Verification

A correct firewall setup has a documented policy, preserves required access, treats IPv4 and IPv6 intentionally, and can be reverted from local console access. Do not judge success only by “the package is installed”.

## References

[1] [Firewalls — Void Linux Handbook](https://docs.voidlinux.org/config/network/firewalls.html)
