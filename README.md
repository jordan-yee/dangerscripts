# dangerscripts

This repo contains my personal Linux configuration files, and scripts for
syncing them with different systems.

## Organization

Each application has its own directory containing all config files relevant
to that application.

## Contents

Below is a list of all included configs/scripts.

| Applications | Scripts        | Installation Path            |
| ------------ | -------------- | ---------------------------- |
| Kakoune      | kakrc          | ~/.config/kak/kakrc          |
| Kakoune      | kakrc-*.kak    | ~/.config/kak/kakrc-*.kak    |
| Kakoune      | custom/*       | ~/.config/kak/custom/*       |
| Kakoune      | highlighters/* | ~/.config/kak/highlighters/* |
| Kakoune      | rc/*           | /usr/local/share/kak/rc/*    |
| Tmux         | .tmux.conf     | ~/.tmux.conf                 |
| Zshell       | .zshrc         | ~/.zshrc                     |
| Flowstorm    | flowstorm/*    | ~/.flow-storm/*              |

Inactive / No Longer Used

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
vimdiff kakoune/kakrc ~/.config/kak/kakrc
vimdiff kakoune/kakrc-filetypes.kak ~/.config/kak/kakrc-filetypes.kak
vimdiff zshell/.zshrc ~/.zshrc
```
