# anchor-jump
#
# - a kakoune plugin for manually managing and navigating a list of jump points
#
# > Set a series of key locations in your open buffers that represent a flow
# > you're working on, then quickly jump through these in sequence or directly.
#
# 1. `:anchor-jump-add`           (<space>-a-a)   when at a few key locations
# 2. `:anchor-jump-next/previous` (<space>-a-j/k) between these locations
# 3. `:anchor-jump-to 1`          (<space>-a-t)   to snap back to the top/start
# 4. `:anchor-jump-menu`          (<space>-a-m)   to pick a location from a menu
# 5. ...and more!

# ------------------------------------------------------------------------------
# Internally Managed Options

declare-option -hidden -docstring "Stores a sequence of locations meant to act
as anchor points for what you're working on: a manually managed jump list." \
str-list anchor_jumps

declare-option -hidden -docstring "Stores a pointer to the current jump point's
starting index in the `anchor_jumps` list." \
int anchor_jump_current 1

# ------------------------------------------------------------------------------
# Commands

define-command -override anchor-jump-reset \
            -docstring 'clear all anchor jumps' %{
    set global anchor_jumps
    set global anchor_jump_current 1
}

define-command -override anchor-jump-debug \
-docstring 'print list of all anchor jumps to debug buffer' %{
    echo -debug ""
    echo -debug "==== anchor_jumps ===="
    # echo -debug %opt{anchor_jumps}
    evaluate-commands %sh{
        eval "set -- $kak_quoted_opt_anchor_jumps"
        if [ $# -gt 0 ]; then
            anchor_num=0
            while [ "$1" ]; do
                anchor_num=$((anchor_num + 1))
                if [ $anchor_num -eq $kak_opt_anchor_jump_current ]; then
                    anchor_num_label="> $anchor_num:"
                else
                    anchor_num_label="  $anchor_num:"
                fi
                printf "echo -debug '$anchor_num_label %s %s %s'\n" "$1" "$2" "$3"
                shift 3
            done
        else
            printf "fail 'no saved anchor jumps'"
        fi
    }
}

# TODO: Add anchor jump after current
define-command -override anchor-jump-add \
-docstring 'add the main selection to your anchor jumps' %{
    set-option -add global anchor_jumps "%val{bufname}" "%val{timestamp}" "%val{selection_desc}"
}

define-command -override -params 1 anchor-jump-to \
-docstring 'go directly to an anchor jump by <number>' %{
    evaluate-commands %sh{
        current=$1
        anchor_head=$(($1 * 3 - 2))
        eval "set -- $kak_quoted_opt_anchor_jumps"

        if [ $# -gt $anchor_head ]; then
            shift $(($anchor_head - 1))
            printf "set global anchor_jump_current %s\n" "$current"
            bufname="$1"
            timestamp="$2"
            selection_desc="$3"
            printf "buffer $bufname;select -timestamp $timestamp $selection_desc\n"
        else
            printf "fail 'specified anchor jump is out of range'"
        fi
    }
}

# TODO: What might we reallly want this to do? How could it be useful?
# - It was the original next command, but I rebranded it to keep the rotation logic...
define-command -override anchor-jump-rotate-forward \
-docstring 'rotate the anchor jump list forward and jump to the new start' %{
    evaluate-commands %sh{
        eval "set -- $kak_quoted_opt_anchor_jumps"

        if [ $# -gt 0 ]; then
            # save first anchor
            bufname="$1"
            timestamp="$2"
            selection_desc="$3"

            # rotate anchor jumps in the list
            shift 3
            # !this resets the current anchor in addition to the list!
            printf "anchor-jump-reset\n"
            while [ "$1" ]; do
                printf "set -add global anchor_jumps \"%s\" \"%s\" \"%s\"\n" "$1" "$2" "$3"
                shift 3
            done
            printf "set -add global anchor_jumps \"%s\" \"%s\" \"%s\"\n" "$bufname" "$timestamp" "$selection_desc"

            # jump to new first anchor
            printf "anchor-jump-to 1\n"
        else
            printf "fail 'no saved anchor jumps'"
        fi
    }
}

define-command -override anchor-jump-next \
-docstring 'go to the next anchor jump' %{
    evaluate-commands %sh{
        eval "set -- $kak_quoted_opt_anchor_jumps"
        next=$(($kak_opt_anchor_jump_current + 1))
        if [ $(($next * 3 - 2)) -gt $# ]; then
            next=1
        fi
        printf "anchor-jump-to %s\n" "$next"
    }
}

define-command -override anchor-jump-prev \
-docstring 'go to the previous anchor jump' %{
    evaluate-commands %sh{
        eval "set -- $kak_quoted_opt_anchor_jumps"
        prev=$(($kak_opt_anchor_jump_current - 1))
        if [ $prev -lt 1 ]; then
            prev=$(($# / 3)) # calc number of last anchor
        fi
        printf "anchor-jump-to %s\n" "$prev"
    }
}

# TODO:
# - jump to each item when tabbing through, like lsp buffer symbols menu
define-command -override anchor-jump-menu \
-docstring 'open a menu of all saved anchor jumps' %{
    evaluate-commands %sh{
        eval "set -- $kak_quoted_opt_anchor_jumps"

        if [ $# -gt 0 ]; then
            anchor_num=0
            printf "menu"
            while [ "$1" ]; do
                anchor_num=$((anchor_num + 1))

                bufname="$1"
                timestamp="$2"
                selection_desc="$3"

                shortened_bufname=$(echo "$bufname" | awk -F/ '{print $NF}')
                selection_starting_line=$(echo "$selection_desc" | awk -F',' '{match($2, /^[0-9]+/, m); print m[0]}')
                menu_name="$anchor_num: $shortened_bufname $selection_starting_line"
                command="anchor-jump-to $anchor_num"

                printf " '%s' '%s'" "$menu_name" "$command"
                shift 3
            done
            printf "\n"
        else
            printf "fail 'no saved anchor jumps'"
        fi
    }
}

# TODO:
define-command -override -hidden anchor-jump-buffer \
-docstring 'open a grep buffer with all your anchor jumps' %{
    fail 'command not implemented'
}

# ------------------------------------------------------------------------------
# Default Custom User Mode / Mappings

define-command -override init-anchor-jump-user-mode \
-docstring 'declare the anchor-jump user mode in a reloadable way' %{
    try %{ declare-user-mode anchor-jump-mode }
    # Ensure old key mappings don't stick around if you change mapped keys.
    unmap global anchor-jump-mode
}

define-command -override register-default-anchor-jump-user-mode-mappings \
-docstring 'register default mappings for anchor-jump user mode' %{
    # modify/update anchor jump list
    map global anchor-jump-mode r ":anchor-jump-reset<ret>" \
        -docstring 'clear all anchor jumps'
    map global anchor-jump-mode a ":anchor-jump-add<ret>" \
        -docstring 'add the main selection to your anchor jumps'
    map global anchor-jump-mode f ":anchor-jump-rotate-forward<ret>" \
        -docstring 'rotate the anchor jump list forward and jump to the new start'

    # navigate anchor jump list
    map global anchor-jump-mode t ":anchor-jump-to 1<ret>" \
        -docstring 'jump directly to top/first anchor jump'
    map global anchor-jump-mode m ":anchor-jump-menu<ret>" \
        -docstring 'open a menu of all saved anchor jumps'
    map global anchor-jump-mode j ":anchor-jump-next<ret>" \
        -docstring 'go to the next anchor jump'
    map global anchor-jump-mode k ":anchor-jump-prev<ret>" \
        -docstring 'go to the previous anchor jump'
    map global anchor-jump-mode n ":anchor-jump-next<ret>" \
        -docstring 'go to the next anchor jump'
    map global anchor-jump-mode p ":anchor-jump-prev<ret>" \
        -docstring 'go to the previous anchor jump'

    # other
    map global anchor-jump-mode d ":anchor-jump-debug<ret>" \
        -docstring 'print list of all anchor jumps to debug buffer'
}
