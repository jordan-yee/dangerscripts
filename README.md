# dangerscripts

This repo contains useful Linux configuration files and scripts.

## Organization

Each application has its own directory containing all config files relevant
to that application.

## Contents

Below is a list of all included configs/scripts.

| Applications | Scripts        | Installation Path            |
| ------------ | -------------- | ---------------------------- |
| Kakoune      | kakrc          | ~/.config/kak/kakrc          |
| Kakoune      | custom/*       | ~/.config/kak/custom/*       |
| Kakoune      | highlighters/* | ~/.config/kak/highlighters/* |
| Kakoune      | rc/*           | /usr/local/share/kak/rc/*    |
| Tmux         | .tmux.conf     | ~/.tmux.conf                 |
| Zshell       | .zshrc         | ~/.zshrc                     |
| Flowstorm    | flowstorm/*    | ~/.flow-storm/*              |

Inactive / No Longer Used

| Applications | Scripts        | Installation Path            |
| Mintty       | .minttyrc      | ~/.minttyrc                  |
| Sakura       | sakura.conf    | ~/.config/sakura/sakura.conf |

## Comparing with local configs

To compare all config files with default local paths:
```shell
./difflocal.sh
```

For files that differ, you can sync them with vimdiff:
```shell
vimdiff kakoune/kakrc ~/.config/kak/kakrc
vimdiff zshell/.zshrc ~/.zshrc
```
