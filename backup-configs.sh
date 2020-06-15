#!/bin/sh
# Backup configs from the home directory to dangerscripts

cp -u ~/.zshrc ~/dangerscripts/.zshrc
echo ".zshrc has been copied to dangerscripts..."

cp -u ~/.tmux.conf ~/dangerscripts/.tmux.conf
echo ".tmux.conf has been copied to dangerscipts..."

cp -u ~/.config/kak/kakrc ~/dangerscripts/kakrc
echo "kakrc has been copied to dangerscipts..."

echo "\nConfig backup complete."
