# dangerscripts

This repo contains my personal Linux configuration files, and scripts for
syncing them with different systems.

## Organization

Each application has its own directory containing all config files relevant
to that application.

## Contents

### Stow Packages

Managed via GNU stow:

| Applications | Package        | Installation Path |
| ------------ | -------------- | ----------------- |
| Kakoune      | kakoune-user   | ~/.config/kak/*   |
| Claude Code  | claude-user    | ~/.claude/*       |

### Manual Install

| Applications | Scripts                      | Installation Path                    |
| ------------ | ---------------------------- | ------------------------------------ |
| Kakoune      | kakoune-local/share/kak/rc/* | /usr/local/share/kak/rc/* (override) |
| Tmux         | .tmux.conf                   | ~/.tmux.conf                         |
| Zshell       | .zshrc                       | ~/.zshrc                             |
| Flowstorm    | flowstorm/                   | ~/.flow-storm/*                      |

### Inactive / No Longer Used

| Applications | Scripts     | Installation Path            |
| ------------ | ----------- | ---------------------------- |
| Mintty       | .minttyrc   | ~/.minttyrc                  |
| Sakura       | sakura.conf | ~/.config/sakura/sakura.conf |

## Installation

### Stow packages

The [Stow Packages](#stow-packages) install with GNU stow. Replace `<package>`
with any package name from that table:

```sh
stow -t ~ <package>     # install (create symlinks)
stow -Rt ~ <package>    # restow after pulling new changes
stow -Dt ~ <package>    # uninstall (remove symlinks)
```

The kakoune-user package additionally needs `plug.kak` and its plugin directory
in place first:

```sh
mkdir -p $HOME/.config/kak/plugins
git clone https://github.com/andreyorst/plug.kak.git $HOME/.config/kak/plugins/plug.kak
```

### Other configs

Everything outside the stow packages — the [Manual Install](#manual-install)
entries and kakoune-local system overrides — should be installed manually or via
your preferred dotfile manager.

## Comparing with local configs

To compare all config files with default local paths:
```sh
./difflocal.sh
```

For files that differ, you can sync them with vimdiff:
```sh
vimdiff kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc
vimdiff kakoune-user/.config/kak/kakrc-filetypes.kak ~/.config/kak/kakrc-filetypes.kak
vimdiff zshell/.zshrc ~/.zshrc
```
