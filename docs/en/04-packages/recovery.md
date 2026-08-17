# VoidLinux-Guide — XBPS Recovery

Treat an XBPS error as evidence about system state. Read the exact message, identify the phase that failed, and avoid replacing package databases or repository files before collecting diagnostics.

## First Response

```sh
sudo xbps-install -S
xbps-query -l | head
cat /etc/xbps.d/*.conf
```

`-S` refreshes repository indexes. Inspect the configured repositories and confirm that architecture and libc match the installation.

## Signature Prompt

If XBPS reports that the Void RSA key changed, compare the displayed fingerprint with the fingerprints in the official `void-packages` and `void-mklive` key directories before importing it. Do not disable signature verification to bypass the prompt. [1]

## `Operation not permitted`

An `Operation not permitted` error while fetching repository metadata can be caused by an incorrect system date or time. Check:

```sh
date
readlink /etc/localtime
sudo sv status <ntp-service>
```

Correct time and timezone before changing repositories. [1]

## `Not Found`

A `Not Found` repository error commonly indicates a wrong path in `/etc/xbps.d`, often due to the wrong architecture or libc path. Check the installed system identity and configured repository files before changing mirrors:

```sh
uname -m
cat /etc/xbps.d/*.conf
```

## Unresolvable Shared Libraries

An `unresolvable shlib` error may result from outdated packages, removed packages or a repository that was removed from configuration. Update first, then inspect orphaned packages:

```sh
sudo xbps-install -Su
sudo xbps-remove -o
```

Do not confirm the orphan removal transaction without reading which packages will be removed. [1]

## Static XBPS

If XBPS can no longer update or install packages, the official Handbook provides a static XBPS recovery path. Follow that page for the current static binary and do not download an unverified replacement from a random forum.

## Evidence to Collect

Record the exact error, the command, `uname -m`, `uname -r`, repository paths, the affected package and the last successful update. Remove tokens, private URLs and usernames before publishing a report.

## References

[1] [Common Issues — Void Linux Handbook](https://docs.voidlinux.org/xbps/troubleshooting/common-issues.html)

[2] [Static XBPS — Void Linux Handbook](https://docs.voidlinux.org/xbps/troubleshooting/static.html)
