diff --brief kakoune-user/.config/kak/kakrc ~/.config/kak/kakrc
for f in kakoune-user/.config/kak/kakrc-*.kak; do diff --brief "$f" ~/.config/kak/"${f##*/}"; done
diff --brief --recursive kakoune-user/.config/kak/custom ~/.config/kak/custom
diff --brief --recursive kakoune-user/.config/kak/highlighters ~/.config/kak/highlighters
diff --brief --recursive kakoune-local/share/kak/rc /usr/local/share/kak/rc | grep -v 'Only in /usr/local/share/kak/rc'
diff --brief tmux/.tmux.conf ~/.tmux.conf
diff --brief zshell/.zshrc ~/.zshrc
diff --brief --recursive flowstorm ~/.flow-storm

# Inactive
# diff --brief mintty/.minttyrc ~/.minttyrc
# diff --brief sakura/sakura.conf ~/.config/sakura/sakura.conf
