#!/bin/bash
# This script uses bash builtins.

# ------------------------------------------------------------------------------
# Path Resolution
#
# Installation paths differ between systems, so resolve them at runtime instead
# of hardcoding them. Each resolved path can be overridden by exporting the
# matching variable before running this script.

# Kakoune user config directory. Kakoune reads this from XDG_CONFIG_HOME,
# falling back to ~/.config.
kak_config="${KAK_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/kak}"

# Kakoune runtime directory. Kakoune resolves this relative to its own binary
# (<prefix>/bin/kak -> <prefix>/share/kak), so distro packages land in
# /usr/share/kak while a default source build lands in /usr/local/share/kak.
resolve_kak_runtime() {
    # Kakoune's own override, if the user has set one.
    if [[ -n "$KAKOUNE_RUNTIME" ]]; then
        echo "$KAKOUNE_RUNTIME"
        return
    fi

    # Derive it the same way Kakoune does, from the binary on PATH.
    local bin
    if bin="$(command -v kak)"; then
        bin="$(readlink -f "$bin")"
        if [[ "$bin" == */bin/kak ]]; then
            echo "${bin%/bin/kak}/share/kak"
            return
        fi
    fi

    # Last resort for systems where Kakoune isn't on PATH.
    local dir
    for dir in /usr/local/share/kak /usr/share/kak; do
        if [[ -d "$dir" ]]; then
            echo "$dir"
            return
        fi
    done
}
kak_runtime="${KAK_RUNTIME_DIR:-$(resolve_kak_runtime)}"

# Side-by-side diff tool used for the manual sync suggestions printed at the
# end. Neovim's diff mode is preferred; vimdiff is the fallback for systems
# without neovim. Empty when neither is installed.
resolve_diff_tool() {
    if command -v nvim > /dev/null; then
        echo "nvim -d"
    elif command -v vimdiff > /dev/null; then
        echo "vimdiff"
    fi
}
diff_tool="$(resolve_diff_tool)"

echo "# Resolved Local Paths:"
echo "kakoune config:  $kak_config"
echo "kakoune runtime: ${kak_runtime:-<not found>}"
echo ""

# ------------------------------------------------------------------------------
# Comparison

mapfile -t differences < <(
    diff --brief kakoune-user/.config/kak/kakrc "$kak_config/kakrc" 2>&1
    for f in kakoune-user/.config/kak/kakrc-*.kak; do
        diff --brief "$f" "$kak_config/${f##*/}" 2>&1
    done
    diff --brief --recursive kakoune-user/.config/kak/custom "$kak_config/custom" 2>&1
    diff --brief --recursive kakoune-user/.config/kak/highlighters "$kak_config/highlighters" 2>&1
    if [[ -n "$kak_runtime" ]]; then
        diff --brief --recursive kakoune-local/share/kak/rc "$kak_runtime/rc" 2>&1 \
            | grep -v "^Only in $kak_runtime/rc"
    else
        echo "Could not locate the kakoune runtime directory; skipped kakoune-local."
    fi
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
if [[ -z "$diff_tool" ]]; then
    echo "No side-by-side diff tool found."
    echo "Install neovim (for 'nvim -d') or vim (for 'vimdiff') to get commands here."
else
    for i in "${!differences[@]}"; do
        line="${differences[$i]}"
        if [[ "$line" =~ ^Files[[:space:]](.+)[[:space:]]and[[:space:]](.+)[[:space:]]differ$ ]]; then
            echo "$((i+1))) $diff_tool ${BASH_REMATCH[1]} ${BASH_REMATCH[2]}"
        fi
    done
fi

# Inactive
# diff --brief mintty/.minttyrc ~/.minttyrc
# diff --brief sakura/sakura.conf ~/.config/sakura/sakura.conf
