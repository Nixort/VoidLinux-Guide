# VoidLinux-Guide — Backups

A backup is a copy that can be restored, not a second path to the same disk. Test restoration before relying on it for a reinstall, filesystem change or bootloader repair.

## Minimum Baseline

Before destructive storage work, preserve:

- User data under `/home`.
- Application and system configuration that you can recreate only with effort.
- A package list for rebuilding the installed set.
- A record of mounts and enabled services.

Useful inspection commands:

```sh
xbps-query -l > "$HOME/package-list.txt"
sudo sv status /var/service/* > "$HOME/service-status.txt"
findmnt > "$HOME/mounts.txt"
```

Review these files for private paths or hostnames before sharing them.

## Test the Copy

Restore a sample file to a temporary directory and compare it with the source. A backup that has never been restored is an assumption, not evidence.

## Before a Risky Change

Record the current kernel, disk layout and boot mode:

```sh
uname -r
lsblk -f
findmnt
```

Do not rely on a backup to justify blind partitioning. The backup must exist and the target device must still be verified independently.
