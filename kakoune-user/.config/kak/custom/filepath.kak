# ------------------------------------------------------------------------------
# Commands for scripting basic kakoune functionality more cleanly.

# NOTE: Ensure the module is source'd ahead of this one:
# source "%val{config}/custom/kakscript.kak"
require-module kakscript # exposes commands prefixed with `kak-`

# ------------------------------------------------------------------------------
# Filepath Mode

try %{ remove-hooks global filepath } # make reloadable

hook -group filepath global RuntimeError 'goto selected file' %{
    # This ridiculous dance is required to set the filetype.
    # This fail-to-exit strategy is probably bypassing the critical hooks,
    # which may be a bug, though to be fair this is kind of a hack.
    execute-keys gf
    delete-buffer
    edit %reg{dot}
}

define-command -override filepath-enable-mappings \
-docstring 'Configure default mappings for filepath-mode commands' %{
    # make reloadable
    try %{ unmap global filepath }
    try %{ declare-user-mode filepath }

    map global filepath j ': filepath-select-next<ret>' -docstring 'select next filepath'
    map global filepath k ': filepath-select-previous<ret>' -docstring 'select previous filepath'
    map global filepath g ": fail 'goto selected file'<ret>" -docstring 'edit selected file'
}

# Known Weaknesses:
# - file paths with spaces, presumably surrounded by quotes
declare-option regex filepath_regex
set-option global filepath_regex "(\.|\b|/)((\w|-)+/?)+(\.[a-z]+)*\b"

# --------------------------------------
# Fail Conditions

declare-option -hidden int filepath_line_difference
define-command -override -hidden filepath-fail-when-negative-difference \
-params 2 \
-docstring 'filepath-fail-when-negative-difference <line number 1> <line number 2>: fails when <line number 1> - <line number 2> is negative' %{
    set-option buffer filepath_line_difference %arg{1}
    set-option -remove buffer filepath_line_difference %arg{2}
    select "%opt{filepath_line_difference}.1,%opt{filepath_line_difference}.1"
}

define-command -override -hidden filepath-fail-when-first-match \
-docstring 'fails if the current selection is the first filepath match in the file' %{
    evaluate-commands -draft -save-regs s %{
        set-register s %val{cursor_line} # initial selection line
        kak-reverse-search %opt{filepath_regex}  # make second selection
        # fails when the search wrapped:
        filepath-fail-when-negative-difference %reg{s} %val{cursor_line}
    }
}

define-command -override -hidden filepath-fail-when-last-match \
-docstring 'fails if the current selection is the last filepath match in the file' %{
    evaluate-commands -draft -save-regs s %{
        set-register s %val{cursor_line} # initial selection line
        kak-search %opt{filepath_regex}  # make second selection
        # fails when the search wrapped:
        filepath-fail-when-negative-difference %val{cursor_line} %reg{s}
    }
}

define-command -override -hidden filepath-fail-when-file-not-found \
-docstring 'fails if the current selection is not an existing file' %{
    evaluate-commands %sh{
        full_path="$(pwd)/$kak_selection"

        if [ -f "$full_path" ]; then
            # printf '%s\n' "echo -debug 'File found: $full_path'"
            printf '%s\n' "echo 'true'"
        else
            # printf '%s\n' "echo -debug 'File not found: $full_path'"
            # This fail output matches the fail output of `gf`.
            printf '%s\n' "fail unable to find file '$kak_selection'"
        fi
    }
}

# --------------------------------------
# filepath-select-next

declare-option str filepath_next_path_selection_desc
define-command -override -hidden filepath-save-next-filepath-selection \
-docstring 'if selection is a filepath to an existing file, save it and throw
error to break outer -itersel' %{
    try %{
        # if
            filepath-fail-when-file-not-found
        # then
            # when selection is a valid filepath, save it
            set-option window filepath_next_path_selection_desc "%val{selection_desc}"
            fail 'filepath found'
    } catch %{
        evaluate-commands %sh{
            if [ "$kak_error" = 'filepath found' ]; then
                # re-throw to immediately break the itersel when a filepath is found
                printf '%s\n' "fail 'filepath found'"
            else
                # we expect file-not-found errors: continue the itersel
                printf '%s\n' "nop"
            fi
        }
    }
}

define-command -override -hidden filepath_find_next_filepath_in_selections \
-docstring 'find next existing filepath in the current selections and save it' \
%{
    unset-option window filepath_next_path_selection_desc
    try %{
        # expecting to break itersel with error when filepath is found
        execute-keys -itersel ': filepath-save-next-filepath-selection<ret>'
    }
}

define-command -override filepath-select-next \
-docstring 'Select the next existing file path in the file' %{
    # TRY SEARCHING TO END OF BUFFER
    evaluate-commands -draft %{
        kak-select-to-end
        # fails when cursor is at end of buffer
        try %{ kak-select-regex %opt{filepath_regex} }
        filepath_find_next_filepath_in_selections
    }
    evaluate-commands %{
        try %{
            select "%opt{filepath_next_path_selection_desc}"
        } catch %{
            # TRY SEARCHING FROM BEGINNING OF BUFFER
            # no filepath found from selection to end of buffer
            # -> wrap around from beginning of buffer to selection
            evaluate-commands -draft %{
                kak-select-to-top
                kak-select-regex %opt{filepath_regex}
                # to be consistent with the forward-selections
                execute-keys <a-semicolon>
                filepath_find_next_filepath_in_selections
            }
            evaluate-commands %{
                try %{
                    select "%opt{filepath_next_path_selection_desc}"
                } catch %{
                    # DONE SEARCHING ENTIRE BUFFER
                    echo -debug 'failure caught in: filepath-select-next'
                    fail 'no filepaths for existing files found'
                }
            }
        }
    }
}

# --------------------------------------
# filepath-select-previous

declare-option str filepath_last_path_selection_desc
define-command -override -hidden filepath-save-last-filepath-selection \
-docstring 'if selection is a filepath to an existing file, save it
(for use with `exec -itersel`)' %{
    try %{
        # if
            # we expect file-not-found errors: continue the itersel
            filepath-fail-when-file-not-found
        # then
            # when selection is a valid filepath, save it
            set-option window filepath_last_path_selection_desc "%val{selection_desc}"
    }
}

define-command -override -hidden filepath_find_prev_filepath_in_selections \
-docstring 'find previous existing filepath in the current selections and save it' \
%{
    unset-option window filepath_last_path_selection_desc
    # expecting itersel to complete successfully
    execute-keys -itersel ': filepath-save-last-filepath-selection<ret>'
}

define-command -override filepath-select-previous \
-docstring 'Select the previous existing file path in the file' %{
    # TRY SEARCHING TO BEGINNING OF BUFFER
    evaluate-commands -draft %{
        kak-select-to-top
        # fails when cursor is at beginning of buffer
        try %{ kak-select-regex %opt{filepath_regex} }
        filepath_find_prev_filepath_in_selections
    }
    evaluate-commands %{
        try %{
            select "%opt{filepath_last_path_selection_desc}"
        } catch %{
            # TRY SEARCHING FROM END OF BUFFER
            # no filepath found from selection to beginning of buffer
            # -> wrap around from end of buffer to selection
            evaluate-commands -draft %{
                kak-select-to-end
                kak-select-regex %opt{filepath_regex}
                # to be consistent with the forward-selections in itersel
                execute-keys <a-semicolon>
                filepath_find_prev_filepath_in_selections
            }
            evaluate-commands %{
                try %{
                    select "%opt{filepath_last_path_selection_desc}"
                } catch %{
                    # DONE SEARCHING ENTIRE BUFFER
                    echo -debug 'failure caught in: filepath-select-previous'
                    fail 'no filepaths for existing files found'
                }
            }
        }
    }
}
