# Contributing to VoidLinux-Guide

VoidLinux-Guide is an English-first, source-verified documentation project. The goal is not to collect command snippets, but to explain a working system model that a reader can inspect and recover.

## Adding a Guide

Place a guide in the stage that owns its subject. A guide should have one narrow purpose, state its prerequisites, explain each command, show the expected result, provide a verification command, and describe limitations or rollback. Do not hide a destructive operation in a generic setup section.

Every technical claim must link to the current Void Linux Handbook or the relevant Void manual page. Community posts, articles and issue discussions may be cited to document a real failure mode, but they must be labelled as community evidence and independently checked against a primary source before becoming a recommendation.

## Command Documentation

For every command, explain the flag or subcommand that matters. Distinguish package installation, index synchronization, package removal, service enablement, service control and configuration editing. Use `#` for root commands and `$` for user commands, or use `sudo` when the command is intended for an ordinary administrator.

Do not translate commands, package names, paths, service names or environment variables. Do not replace runit commands with systemd commands. If a command depends on architecture, libc, desktop environment, driver or an existing service, state that dependency directly before the command.

## Translation Policy

English files under `docs/en/` are canonical. Translators may create the same file under a language directory, but must preserve command blocks, file paths, warning severity, expected output, verification steps and links. A translation may be more natural than a literal copy, but it must not change technical meaning.

## Review Checklist

| Review item | Requirement |
|---|---|
| Stage | The file belongs to one clearly named stage. |
| Scope | Hardware, libc, architecture and prerequisites are explicit. |
| Commands | Every command is explained and uses Void/runit/XBPS conventions. |
| Verification | The reader can check success without guessing. |
| Safety | Destructive, remote-access and bootloader risks are visible before execution. |
| Sources | Official sources are present; community evidence is clearly labelled. |
| Language | Canonical content is English; translations preserve technical blocks. |
| Links | Internal navigation and external references resolve. |
