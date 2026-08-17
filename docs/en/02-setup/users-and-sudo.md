# VoidLinux-Guide — Users and Sudo

Use an ordinary user for daily work and elevate only the command that requires administrative access. This keeps the scope of mistakes smaller and makes command history easier to interpret.

## Inspect the Current Account

```sh
id
groups
```

`id` shows the user and numeric identity; `groups` shows supplementary groups. Do not add groups without understanding the device or service access they provide.

## Configure `wheel`

Void installs `sudo` by default, but its policy may need to be enabled. Use `visudo`, which validates the file before saving it:

```sh
sudo visudo
```

Uncomment the rule below if it is not already active:

```text
%wheel ALL=(ALL) ALL
```

The `wheel` group grants elevated privileges through this rule. Add the intended user:

```sh
sudo usermod -aG wheel <username>
```

`usermod -aG` appends a supplementary group; omitting `-a` can replace existing supplementary groups. Log out and back in before testing the new membership.

```sh
groups
sudo -v
sudo id -u
```

`sudo -v` validates the sudo policy and credentials. `sudo id -u` should print `0` without turning the entire shell into a root shell.

## Change a Password

Use `passwd` rather than editing account files:

```sh
passwd
```

Use a unique root password and a different ordinary-user password. Never place passwords in commands, scripts, issue reports or screenshots.

## References

[1] [Users and Groups — Void Linux Handbook](https://docs.voidlinux.org/config/users-and-groups.html)

[2] [sudo(8) — Void Linux Manual Pages](https://man.voidlinux.org/sudo.8)
