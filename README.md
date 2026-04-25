# dangerscripts

This repo contains my personal Linux configuration files, and scripts for
syncing them with different systems.

## Organization

Each application has its own directory containing all config files relevant
to that application.

## Installation

Kakoune configs can be installed using GNU stow. Two separate packages target different directories:

```bash
# Install user-level Kakoune config (~/.config/kak)
stow -t ~ kakoune-user

# Install system-level Kakoune rc files (/usr/local/share/kak)
# Note: /usr/local may require sudo or write permissions
stow -t /usr/local kakoune-local
```

Other configs below should be installed manually or via your preferred dotfile manager.

## Contents

### Stow Packages

Managed via GNU stow:

| Applications | Package        | Installation Path       |
| ------------ | -------------- | ----------------------- |
| Kakoune      | kakoune-user   | ~/.config/kak/*         |
| Kakoune      | kakoune-local  | /usr/local/share/kak/*  |

### Manual Install

| Applications | Scripts    | Installation Path     |
| ------------ | ---------- | --------------------- |
| Tmux         | .tmux.conf | ~/.tmux.conf          |
| Zshell       | .zshrc     | ~/.zshrc              |
| Flowstorm    | flowstorm/ | ~/.flow-storm/*       |

### Inactive / No Longer Used

| Applications | Scripts     | Installation Path            |
| ------------ | ----------- | ---------------------------- |
| Mintty       | .minttyrc   | ~/.minttyrc                  |
| Sakura       | sakura.conf | ~/.config/sakura/sakura.conf |

## Comparing with local configs

To compare all config files with default local paths:
```shell
./difflocal.sh
```

For files that differ, you can sync them with vimdiff:
```shell
vimdiff kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc
vimdiff kakoune-user/.config/kak/kakrc-filetypes.kak ~/.config/kak/kakrc-filetypes.kak
vimdiff zshell/.zshrc ~/.zshrc
```
