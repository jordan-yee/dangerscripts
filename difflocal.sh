#!/bin/bash
# This script uses bash builtins.

mapfile -t differences < <(
    diff --brief kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc 2>&1
    for f in kakoune-user/.config/kak/kakrc-*.kak; do
        diff --brief "$f" ~/.config/kak/"${f##*/}" 2>&1
    done
    diff --brief --recursive kakoune-user/.config/kak/custom ~/.config/kak/custom 2>&1
    diff --brief --recursive kakoune-user/.config/kak/highlighters ~/.config/kak/highlighters 2>&1
    diff --brief --recursive kakoune-local/share/kak/rc /usr/local/share/kak/rc 2>&1 | grep -v 'Only in /usr/local/share/kak/rc'
    diff --brief tmux/.tmux.conf ~/.tmux.conf 2>&1
    diff --brief zshell/.zshrc ~/.zshrc 2>&1
    diff --brief --recursive flowstorm ~/.flow-storm 2>&1
)

if [[ ${#differences[@]} -eq 0 ]]; then
    echo "No differences detected."
    exit 0
fi

echo "# Detected Differences:"
for i in "${!differences[@]}"; do
    echo "$((i+1))) ${differences[$i]}"
done

echo ""
echo "# To View Specific Differences:"
for i in "${!differences[@]}"; do
    line="${differences[$i]}"
    if [[ "$line" =~ ^Files[[:space:]](.+)[[:space:]]and[[:space:]](.+)[[:space:]]differ$ ]]; then
        echo "$((i+1))) vimdiff ${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
    fi
done

# Inactive
# diff --brief mintty/.minttyrc ~/.minttyrc
# diff --brief sakura/sakura.conf ~/.config/sakura/sakura.conf
