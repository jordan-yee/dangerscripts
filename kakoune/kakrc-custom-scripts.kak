# ------------------------------------------------------------------------------
# Custom / Experimental Scripts

source "%val{config}/custom/kakscript.kak"

# search user mode
# ----------------

source "%val{config}/custom/search.kak"
map global user / ': enter-user-mode search<ret>' -docstring 'search mode'
map global search j ':set global jumpclient %val{client}<ret>' -docstring 'set current client as jumpclient'
map global search J ":unset global jumpclient" -docstring 'clear jumpclient'
map global search t ':set global toolsclient %val{client}<ret>' -docstring 'set current client as toolsclient'
map global search T ":unset global toolsclient" -docstring 'clear toolsclient'

# Unix diff utility
# -----------------

source "%val{config}/custom/diff.kak"

# repl/window function fixes for dwm + sakura
# -------------------------------------------

# source "%val{confing}/custom/repl-windowing-dwm-sakura.kak"

# Quickly insert a section comment
# --------------------------------

source "%val{config}/custom/comment-sections.kak"
install-comment-mode-mappings
map global user c ': enter-user-mode comment-mode<ret>' -docstring 'comment mode'

# Depth-first grep searches
# -------------------------

source "%val{config}/custom/grep-stack.kak"

# Quickly select & navigate filepaths
# -----------------------------------

source "%val{config}/custom/filepath.kak"
filepath-enable-mappings
map global selection f ': enter-user-mode -lock filepath<ret>j' -docstring 'select next filepath & lock filepath mode'

# Wrap text to within autowrap_column
# -----------------------------------

source "%val{config}/custom/wrap-mode.kak"

# open instance of br on the left
# -------------------------------

define-command -override open-br \
-docstring 'Open an instance of br file browser on the left.' %{
    nop %sh{ zsh -c 'tmux split-window -hbf -l 80; tmux send-keys br C-m' }
    echo 'Opening br...'
}

alias global br open-br

# expand tmux pane width to fit buffer contents
# ---------------------------------------------

source "%val{config}/custom/auto-window-resize.kak"

# quickly spawn new clients at the current position
# -------------------------------------------------

define-command -override new-here -params 1..2 \
-docstring 'new-here <placement> [<command>]: open a new client to the current
position in a split with the specified <placement>

uses the configured %opt{windowing_module}

optionally, provide additional <command> to be executed in the context of the
new client on initialization' %{
    evaluate-commands %sh{
        # set target window placement
        printf "%s\n" "set local windowing_placement $1"
        # compose start of command
        printf "%s" \
        "terminal kak -c $kak_session -e 'edit $kak_buffile $kak_cursor_line $kak_cursor_column"
        # inject optional parameter
        if [ $# -gt 1 ]; then
            printf "%s" ";$2"
        fi
        # compose end of command
        printf "%s\n" "'"
    }
}
complete-command new-here shell-script-candidates %{
    case "$kak_token_to_complete" in
        0) printf "%s\n" horizontal vertical window;;
    esac
}

define-command -override new-here-horizontal -params ..1 -command-completion \
-docstring 'new-here-horizontal [<command>]: open a new client to the current
position in a horizontal split

uses the configured %opt{windowing_module}

optionally, provide additional <command> to be executed in the context of the
new client on initialization' %{
    new-here horizontal %arg{1}
}
alias global newh new-here-horizontal

define-command -override new-here-vertical -params ..1 -command-completion \
-docstring 'new-here-vertical [<command>]: open a new client to the current
position in a vertical split

uses the configured %opt{windowing_module}

optionally, provide additional <command> to be executed in the context of the
new client on initialization' %{
    new-here vertical %arg{1}
}
alias global newv new-here-vertical

define-command -override new-here-window -params ..1 -command-completion \
-docstring 'new-here-window [<command>]: open a new client to the current
position in a new window/tab

uses the configured %opt{windowing_module}

optionally, provide additional <command> to be executed in the context of the
new client on initialization' %{
    new-here window %arg{1}
}
alias global neww new-here-window

# (Hug)SQL helper commands
# ------------------------

source "%val{config}/custom/sql.kak"
