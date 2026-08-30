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

# Hyprland user config directory. Hyprland reads this from XDG_CONFIG_HOME,
# falling back to ~/.config.
hypr_config="${HYPR_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/hypr}"

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
echo "kakoune config: $kak_config"
echo "hyprland config: $hypr_config"
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
    for f in hyprland-user/.config/hypr/*.lua; do
        diff --brief "$f" "$hypr_config/${f##*/}" 2>&1
    done
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

# Only the "Files X and Y differ" entries name a pair that can be opened side
# by side; the rest are diff's own messages about missing files.
syncable_numbers=()
syncable_pairs=()
for i in "${!differences[@]}"; do
    line="${differences[$i]}"
    if [[ "$line" =~ ^Files[[:space:]](.+)[[:space:]]and[[:space:]](.+)[[:space:]]differ$ ]]; then
        syncable_numbers+=("$((i+1))")
        syncable_pairs+=("${BASH_REMATCH[1]} ${BASH_REMATCH[2]}")
    fi
done

if [[ ${#syncable_pairs[@]} -gt 0 ]]; then
    echo ""
    echo "# To View Specific Differences:"
    if [[ -z "$diff_tool" ]]; then
        echo "No side-by-side diff tool found."
        echo "Install neovim (for 'nvim -d') or vim (for 'vimdiff') to get commands here."
    else
        for i in "${!syncable_pairs[@]}"; do
            echo "${syncable_numbers[$i]}) $diff_tool ${syncable_pairs[$i]}"
        done
    fi
fi

# Inactive
# diff --brief mintty/.minttyrc ~/.minttyrc
# diff --brief sakura/sakura.conf ~/.config/sakura/sakura.conf
