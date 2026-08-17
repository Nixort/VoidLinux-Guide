# VoidLinux-Guide — Update Lifecycle

Void updates are transactions. Treat the preview, package state, service state and reboot as separate checkpoints.

## Update

```sh
sudo xbps-install -Su
```

If the `xbps` package was updated, run the command again. Do not interrupt the transaction or close the terminal while XBPS is changing package state. [1]

## Services Are Not Restarted Automatically

After an update, identify processes still using deleted binaries:

```sh
xcheckrestart
```

XBPS leaves service restarts to the administrator so that maintenance windows and dependencies can be considered. Restart only the affected service:

```sh
sudo sv status <service>
sudo sv restart <service>
```

## Reboot Decision

Reboot after a kernel, initramfs, core libc or display-session update when the package documentation or service state makes a reboot appropriate. Verify the new kernel after reboot:

```sh
uname -r
```

## Record Changes

For a server or important workstation, record the date, transaction summary, reboot decision, service restarts and any held packages. This turns “it broke after an update” into a traceable event.

## References

[1] [XBPS Package Manager — Void Linux Handbook](https://docs.voidlinux.org/xbps/index.html)
