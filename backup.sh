#!/bin/sh
# Backup configs from the home directory to dangerscripts

cp -u ~/.zshrc ~/dangerscripts/.zshrc
cp -u ~/.tmux.conf ~/dangerscripts/.tmux.conf
cp -u ~/.config/kak/kakrc ~/dangerscripts/kakrc
