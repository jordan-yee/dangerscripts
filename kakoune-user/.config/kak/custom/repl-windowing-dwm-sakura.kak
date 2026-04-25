# This script contains repl/window function fixes for dwm (X11) + Sakura.

# Does not currently work. WINDOWID is not set appropriately for each client.
define-command dwm-focus -params ..1 -client-completion -docstring '
x11-focus [<kakoune_client>]: focus a given client''s window
If no client is passed, then the current client is used' \
%{
    evaluate-commands %sh{
        if [ $# -eq 1 ]; then
            printf "evaluate-commands -client '%s' dwm-focus" "$1"
        else
            # Command returning the same value for all clients
            xdotool click --window ${kak_client_env_WINDOWID} 1 > /dev/null ||
            echo 'fail failed to run x11-focus, see *debug* buffer for details'
        fi
    }
}

# Working to create a new repl window on the top of the current active stack's tag
define-command -docstring %{
    x11-repl [<arguments>]: create a new window for repl interaction
    All optional parameters are forwarded to the new window
} \
    -params .. \
    -shell-completion \
    dwm-repl %{ evaluate-commands %sh{
        if [ -z "${kak_opt_termcmd}" ]; then
           echo 'fail termcmd option is not set'
           exit
        fi
        if [ $# -eq 0 ]; then cmd="${SHELL:-sh}"; else cmd="$@"; fi
        setsid ${kak_opt_termcmd} ${cmd} -t 'kak_repl_window' < /dev/null > /dev/null 2>&1 &
        # The escape sequence in the printf command sets the terminal's title:
        #setsid ${kak_opt_termcmd} "printf '\e]2;kak_repl_window\a' && ${cmd}" < /dev/null > /dev/null 2>&1 &
}}

# xdotool click --window $(xdotool search --name target) 1 key Shift+Insert

# Only working if the window is in the active tag.
define-command dwm-send-text -docstring "send the selected text to the repl window" %{
    evaluate-commands %sh{
        # Usage:
        # `focus(${repl_window_id})`
        focus () {
            xdotool click --window $1 1
        }

        # Usage:
        # `send_keys(${repl_window_id})`
        send_keys () {
            xdotool click --window $1 1 key --clearmodifiers Shift+Insert
        }

        repl_window_title=kak_repl_window
        repl_window_id=$(xdotool search --name ${repl_window_title})

        printf %s\\n "${kak_selection}" | xsel -i ||
        echo 'fail x11-send-text: failed to run xsel, see *debug* buffer for details' &&
        xdotool click --window ${repl_window_id} 1 key --clearmodifiers Shift+Insert ||
        echo 'fail x11-send-text: failed to run xdotool, see *debug* buffer for details'
    }
}
