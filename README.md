# dangerscripts

This repo contains my personal Linux configuration files, and scripts for
syncing them with different systems.

## Organization

Each application has its own directory containing all config files relevant
to that application.

## Contents

### Stow Packages

Managed via GNU stow:

| Applications    | Package       | Installation Path   |
| --------------- | ------------- | ------------------- |
| Kakoune         | kakoune-user  | ~/.config/kak/*     |
| Claude Code     | claude-user   | ~/.claude/*         |
| Hyprland        | hyprland-user | ~/.config/hypr/*    |
| Lazygit         | lazygit-user  | ~/.config/lazygit/* |
| Tmux (Omarchy)  | omarchy-tmux  | ~/.config/tmux/*    |
| Herdr (Omarchy) | omarchy-herdr | ~/.config/herdr/*   |

### Manual Install

| Applications | Scripts    | Installation Path |
| ------------ | ---------- | ----------------- |
| Tmux         | .tmux.conf | ~/.tmux.conf      |
| Zshell       | .zshrc     | ~/.zshrc          |
| Flowstorm    | flowstorm/ | ~/.flow-storm/*   |

### Inactive / No Longer Used

| Applications | Scripts     | Installation Path            |
| ------------ | ----------- | ---------------------------- |
| Mintty       | .minttyrc   | ~/.minttyrc                  |
| Sakura       | sakura.conf | ~/.config/sakura/sakura.conf |

### Docs

The `docs/` directory contains documentation describing common setups, meant
for quick reference when setting things up on different systems.

- [SSH Setup](./docs/ssh-setup.md)
- [Kakoune as the default editor on Omarchy](./docs/kakoune-omarchy.md)

## Installation

### Stow packages

The [Stow Packages](#stow-packages) install with GNU stow. Replace `<package>`
with any package name from that table:

```sh
stow -t ~ <package>     # install (create symlinks)
stow -Rt ~ <package>    # restow after pulling new changes
stow -Dt ~ <package>    # uninstall (remove symlinks)
```

**Special steps/considerations for the kakoune-user package:**

The kakoune-user package additionally needs `plug.kak` and its plugin
directory in place **before** stowing it:

```sh
mkdir -p $HOME/.config/kak/plugins
git clone https://github.com/andreyorst/plug.kak.git $HOME/.config/kak/plugins/plug.kak
```

> Do not skip that order! If `~/.config/kak` does not already exist, stow folds
> the whole directory into a single symlink pointing back into this repo. Then
> the plug.kak clone and anything created under `~/.config/kak`is written into
> the working tree instead of into your home directory.
> Creating the directories first forces stow to symlink the individual files
> inside them, which leaves `~/.config/kak` a real directory that local-only
> content can live in.

To repair an install that already folded, remove the clone from this repo's
working tree, then:

```sh
stow -Dt ~ kakoune-user     # remove the folded symlink
mkdir -p $HOME/.config/kak/plugins
git clone https://github.com/andreyorst/plug.kak.git $HOME/.config/kak/plugins/plug.kak
stow -t ~ kakoune-user      # restow, now unfolded
```

Check `git status` before restowing either way. Stow exports whatever it finds
in the package, so leftovers from a folded install get symlinked back out and
carry on writing into the working tree.

**Special steps/considerations for the hyprland-user package:**

This package tracks only the files in `hyprland-user/.config/hypr/`; anything
else in `~/.config/hypr` is left alone. They are overrides for Omarchy 4's
default hyprland settings, which include other config files in that directory,
but should work just as well for other hyprland installations.

For the first install on a system, create the directory first (for the same
reason described for kakoune-user above), then remove Omarchy's copies of the
tracked files, since stow refuses to overwrite files it does not own:

```sh
mkdir -p $HOME/.config/hypr
for f in hyprland-user/.config/hypr/*; do rm -f "$HOME/.config/hypr/${f##*/}"; done
stow -t ~ hyprland-user
```

`omarchy refresh hyprland` (and `omarchy refresh config hypr/...`) overwrites
the tracked files with `cp`, which follows the stow symlinks and clobbers the
copies in this repo. Unstow first to avoid that:

```sh
stow -Dt ~ hyprland-user
omarchy refresh hyprland
stow -t ~ hyprland-user
```

If a refresh ran while stowed, the symlinks survive, so restoring the repo
files is the whole fix. Omarchy backs up each file it replaces as
`<file>.bak.<timestamp>` in `~/.config/hypr`, so uncommitted edits can be
recovered from there before deleting the backups:

```sh
git checkout -- hyprland-user
rm $HOME/.config/hypr/*.bak.*
```

**Special steps/considerations for the lazygit-user package:**

This package tracks the single file `~/.config/lazygit/config.yml`. As with the
packages above, create the directory first so stow symlinks the file rather
than folding the whole directory:

```sh
mkdir -p $HOME/.config/lazygit
```

Stow refuses to overwrite a file it does not own, so remove (or back up) an
existing config before the first install on a system:

```sh
rm $HOME/.config/lazygit/config.yml
stow -t ~ lazygit-user
```

The `os.editPreset` setting in this config is what makes lazygit's `e` binding
open Kakoune instead of falling back to Vim; see
[Kakoune as the default editor on Omarchy](./docs/kakoune-omarchy.md) for why
that is needed. The `git.diffRenderers` entries require
[delta](https://github.com/dandavison/delta) to be installed.

**Special steps/considerations for the omarchy-tmux package:**

This package tracks the single file `~/.config/tmux/tmux.conf`, a customized
version of Omarchy's default tmux config. It is separate from the older
`tmux/.tmux.conf` in [Manual Install](#manual-install), which is for non-Omarchy
systems. As with the packages above, create the directory first so stow
symlinks the file rather than folding the whole directory, and remove Omarchy's
copy since stow refuses to overwrite a file it does not own:

```sh
mkdir -p $HOME/.config/tmux
rm $HOME/.config/tmux/tmux.conf
stow -t ~ omarchy-tmux
```

Like the Hyprland configs, an Omarchy refresh of the tmux config would follow
the symlink and overwrite the copy in this repo, so unstow before refreshing
and restow afterwards. If that already happened, restore it with
`git checkout -- omarchy-tmux`.

**Special steps/considerations for the omarchy-herdr package:**

This package tracks the single file `~/.config/herdr/config.toml`, which maps
the omarchy-tmux keybindings and look onto herdr (tmux sessions, windows and
panes become herdr workspaces, tabs and panes). Comments at the top of the file
list the tmux bindings herdr has no equivalent for. Install it the same way as
omarchy-tmux:

```sh
mkdir -p $HOME/.config/herdr
rm $HOME/.config/herdr/config.toml
stow -t ~ omarchy-herdr
```

The other files herdr keeps in `~/.config/herdr` are runtime state, not config,
and are deliberately left untracked:

- `session.json` - the saved layout (workspaces, tabs, panes and their working
  directories) that herdr writes on exit and restores on the next start.
- `herdr-server.log` / `herdr-client.log` - logs from the herdr server and
  client processes, useful only for debugging.
- `.plugins.lock` - an empty lock file herdr uses to coordinate plugin
  operations between processes.
- `config.toml.bak.<timestamp>` - a backup of a replaced config; safe to delete
  once the tracked config is confirmed working.

### Other configs

Everything outside the stow packages - the [Manual Install](#manual-install)
entries - should be installed manually or via your preferred dotfile manager.

## Comparing with local configs

To compare all config files with local paths:
```sh
./difflocal.sh
```

The Kakoune and Hyprland config directories follow `XDG_CONFIG_HOME` rather
than being assumed to be `~/.config/kak` and `~/.config/hypr`. The script prints
the paths it resolved before diffing, and they can be overridden for unusual
layouts:

```sh
KAK_CONFIG_DIR=~/dotfiles/kak ./difflocal.sh
HYPR_CONFIG_DIR=~/dotfiles/hypr ./difflocal.sh
```

For files that differ, you can sync them side by side in Neovim's diff mode:
```sh
nvim -d kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc
nvim -d kakoune-user/.config/kak/kakrc-filetypes.kak ~/.config/kak/kakrc-filetypes.kak
nvim -d hyprland-user/.config/hypr/bindings.lua ~/.config/hypr/bindings.lua
nvim -d zshell/.zshrc ~/.zshrc
```

On systems without Neovim, `vimdiff` takes the same arguments and works the
same way:
```sh
vimdiff kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc
```
