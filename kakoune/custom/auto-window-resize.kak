# Commands & Mappings to auto-resize the width of a tmux pane to fit the
# contents without wrapping.

declare-option int max_window_width 150

declare-option int current_gutter_width
declare-option int current_view_width
define-command -override fit-width-to-longest-selected-line \
-docstring 'expand window width to fit selected lines' %{
    set-option window current_gutter_width %sh{
        # the 2 is for a gutter symbol + the line following the line number
        printf "%s" $((${#kak_buf_line_count} + 2))
    }
    set-option window current_view_width %val{window_width}
    set-option -remove window current_view_width %opt{current_gutter_width}
    evaluate-commands -draft %{
        try %{ execute-keys "x<a-s><a-k>.{%opt{current_view_width}}<ret>" }
        echo -debug %sh{
            max() {
                echo "$@" | tr ' ' '\n' | sort -nr | head -n 1
            }
            min() {
                echo "$@" | tr ' ' '\n' | sort -n | head -n 1
            }
            longest_line=$(max $kak_selections_length)
            if [ "$longest_line" -ge "$kak_opt_current_view_width" ]; then
                fit_width=$(($longest_line + $kak_opt_current_gutter_width))
                tmux resize-pane -x $(min $fit_width $kak_opt_max_window_width)
            fi
        }
    }
}
map global user x ":fit-width-to-longest-selected-line<ret>" \
-docstring 'expand window width to fit selected lines'

define-command -override fit-width-to-longest-line-in-buffer \
-docstring 'expand window width to fit all lines in buffer' %{
    # this is wrapped in a command to restore mark register
    execute-keys 'Z%:fit-width-to-longest-selected-line<ret>z'
}
map global user X ":fit-width-to-longest-line-in-buffer<ret>" \
-docstring 'expand window width to fit longest line in buffer'
