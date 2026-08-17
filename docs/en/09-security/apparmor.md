# VoidLinux-Guide — AppArmor

AppArmor is mandatory access control that constrains programs with profiles. It is useful when the system has a clear profile and monitoring plan; enabling it without a recovery path can turn a policy mistake into a boot or service problem.

## Install and Enable

```sh
sudo xbps-install -S apparmor
```

Void's AppArmor guide requires the kernel command line parameters:

```text
apparmor=1 security=apparmor
```

Add them using the bootloader's documented kernel-command-line mechanism, then regenerate or update the boot configuration as required by that bootloader. Reboot and verify policy status using the AppArmor tools available on the system.

## Enforce and Complain

AppArmor boots in enforce mode by default and blocks policy violations. `apparmor.mode=complain` can be used for a deliberate learning or policy-generation phase; it is not the same security posture as enforce mode. [1]

Profile-generation tools such as `aa-genprof` and `aa-logprof` require configured syslog or a running `auditd` service. Install and verify logging before expecting those tools to explain violations.

## Recovery Plan

Before enabling AppArmor on a remote machine, keep console access and document how to remove the kernel parameters from the boot entry. Change one profile at a time and test the affected service. Record the policy, mode and observed denials.

## References

[1] [AppArmor — Void Linux Handbook](https://docs.voidlinux.org/config/security/apparmor.html)

[2] [Kernel Command Line — Void Linux Handbook](https://docs.voidlinux.org/config/kernel.html)
