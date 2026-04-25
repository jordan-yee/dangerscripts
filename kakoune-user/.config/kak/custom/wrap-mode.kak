# !Quick-Dev Compatible! - (keep this code reloadable)
# A Kakoune plugin to assist with wrapping within a target column.
# Utilizes the built-in autowrap.kak and comment.kak scripts.

define-command -override format-wrap-selections \
-docstring 'Re-format selected text to within autowrap_column chars' %{
    autowrap-enable
    set-option window autowrap_format_paragraph true

    # Here's an attempt to rebalance all text in selection. This seems worse
    # than only fixing long lines most of the time.
    # The stuff at the end was attempting to fix an issue with this eating
    # blank lines after the selection:
    # execute-keys -with-hooks -draft 'Z<a-;><a-j>i<space><esc>hdz<a-:>ho<esc>h'

    execute-keys -with-hooks -draft '<a-;>i<space><esc>hd'
    unset-option window autowrap_format_paragraph
    autowrap-disable
}

define-command -override -hidden fail-if-exceeds-autowrap-column \
-docstring 'Trigger an error if the current line length exceeds autowrap_column' %{
    execute-keys xH # select entire line minus trailing newline
    evaluate-commands %sh{
        # TODO: debug buffer sometimes has output like:
        # shell stderr: <<<
        # /bin/sh: 3: [: Illegal number: 20 20
        # >>>
        if [ "$kak_selection_length" -ge "$kak_opt_autowrap_column" ]; then
            printf '%s\n' "fail 'line exceeds autowrap column'"
        else
            printf '%s\n' 'nop'
        fi
    }
}

# TODO: This sometimes messes with indentation of a line futher down?
define-command -override format-wrap-line \
-docstring 'Wrap the current line to autowrap_column chars' %{
    try %{
        evaluate-commands -draft fail-if-exceeds-autowrap-column
        # last iteration will pass through to here
        execute-keys gl
    } catch %{
        # with-hooks makes things like auto-commenting on newline work
        execute-keys -with-hooks "gh%opt{autowrap_column}l<a-f><space>;c<ret><esc>"
        # NOTE: this shells out each iteration
        format-wrap-line # recurse until the entire line is < autowrap_column
    }
}

define-command -override select-comment-lines \
-docstring 'Filter the current selection to only include comment lines' %{
    execute-keys '<a-s><a-k>^\h*#<ret><a-_>'
}

# TODO: This sometimes messes with indentation of a line futher down.
define-command -override format-upper-comment-lines \
-docstring 'Re-format block of comment lines at the top of the current paragraph to stay within autowrap_column chars' %{
    execute-keys ,        # keep only main selection
    execute-keys '<a-i>p' # select current paragraph
    select-comment-lines  # select sets of contiguous comment lines
    execute-keys '),'     # select only first set of comment lines
    comment-line          # un-comment selected lines
    execute-keys '<a-j>'  # Merge comment text onto 1 line
    comment-line          # re-comment single, merged line
    format-wrap-line
}

# TODO: Wrap this stuff in commands to be explicitly called in kakrc
try %{ declare-user-mode format-wrap }
map global user w ': enter-user-mode format-wrap<ret>' \
-docstring "format-wrap mode"
map global format-wrap w ': format-wrap-selections<ret>' \
-docstring "[STABLE-ISH] reformat selection to keep lines < %opt{autowrap_column} chars"
map global format-wrap l ': format-wrap-line<ret>' \
-docstring "[STABLE-ISH] wrap current line to be < %opt{autowrap_column} chars"
map global format-wrap u ': format-upper-comment-lines<ret>' \
-docstring "[STABLE-ISH] Re-format upper block of comment lines to stay within %opt{autowrap_column} chars"
