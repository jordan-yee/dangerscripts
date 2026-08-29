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

| Applications | Scripts                      | Installation Path |
| ------------ | ---------------------------- | ----------------- |
| Kakoune      | kakoune-local/share/kak/rc/* | `<kak-runtime>`/rc/* (override) |
| Tmux         | .tmux.conf                   | ~/.tmux.conf      |
| Zshell       | .zshrc                       | ~/.zshrc          |
| Flowstorm    | flowstorm/                   | ~/.flow-storm/*   |

### Installation Paths

Two Kakoune paths vary between systems, so nothing here hardcodes them:

- **`<kak-runtime>`** - Kakoune resolves its runtime directory relative to its
  own binary, as `<prefix>/bin/kak` → `<prefix>/share/kak`. A default source
  build gives `/usr/local/share/kak`; a distro package gives `/usr/share/kak`.
  Check with `kak -ui dummy -e 'echo -to-file /dev/stdout %val{runtime}; quit'`.
- **`~/.config/kak`** - the user config directory follows `XDG_CONFIG_HOME`
  when that is set to something other than `~/.config`.

Note that overriding runtime files under `<kak-runtime>` needs root and is
reverted whenever the package manager upgrades Kakoune.

### Inactive / No Longer Used

| Applications | Scripts     | Installation Path            |
| ------------ | ----------- | ---------------------------- |
| Mintty       | .minttyrc   | ~/.minttyrc                  |
| Sakura       | sakura.conf | ~/.config/sakura/sakura.conf |

### Docs

The `docs/` directory contains documentation describing common setups, meant
for quick reference when setting things up on different systems.

- [SSH Setup](./docs/ssh-setup.md)

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

Everything outside the stow packages - the [Manual Install](#manual-install)
entries and kakoune-local system overrides - should be installed manually or via
your preferred dotfile manager.

## Comparing with local configs

To compare all config files with local paths:
```sh
./difflocal.sh
```

The script resolves the Kakoune paths described in [Installation
Paths](#installation-paths) and prints what it picked before diffing. Both can
be overridden for unusual layouts:

```sh
KAK_RUNTIME_DIR=/opt/kakoune/share/kak ./difflocal.sh
KAK_CONFIG_DIR=~/dotfiles/kak ./difflocal.sh
```

For files that differ, you can sync them side by side in Neovim's diff mode:
```sh
nvim -d kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc
nvim -d kakoune-user/.config/kak/kakrc-filetypes.kak ~/.config/kak/kakrc-filetypes.kak
nvim -d zshell/.zshrc ~/.zshrc
```

On systems without Neovim, `vimdiff` takes the same arguments and works the
same way:
```sh
vimdiff kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc
```
