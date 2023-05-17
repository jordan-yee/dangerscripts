# ------------------------------------------------------------------------------
# Commands for scripting basic kakoune functionality more cleanly.
# TODO: Move this to a shared lib/script

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
    execute-keys -draft gf
}

declare-option str filepath_existing_path_selection_desc
define-command -override -hidden filepath-save-existing-filepath-selections \
-docstring 'if selection is a filepath to an existing file, save it
(for use with `exec -itersel`)' %{
    try %{
        # if
        filepath-fail-when-file-not-found
        # then
        set-option window filepath_existing_path_selection_desc "%val{selection_desc}"
    }
}
define-command -override -hidden filepath-fail-when-existing-filepaths-not-found \
-docstring 'fails if there are no existing filepaths found in the file' %{
    evaluate-commands -draft %{
        kak-select-all
        kak-select-regex %opt{filepath_regex}
        unset-option window filepath_existing_path_selection_desc
        execute-keys -itersel ': filepath-save-existing-filepath-selections<ret>'
        try %{ select "%opt{filepath_existing_path_selection_desc}" } catch %{
            fail 'no filepaths for existing files found'
        }
    }
}

# --------------------------------------
# filepath-select-next

define-command -override -hidden filepath-select-next-loop \
-docstring 'Select the next existing file path in the file' %{
    kak-clear-secondary-selections
    kak-search %opt{filepath_regex} # select the next potential filepath string
    try %{
        filepath-fail-when-file-not-found
    } catch %{
        filepath-fail-when-existing-filepaths-not-found
        # if file contains filepaths to existing files, then recurse until finding one
        filepath-select-next-loop
    }
}

define-command -override filepath-select-next \
-docstring 'Select the next existing file path in the file' %{
    try %{
        kak-save-selections
        filepath-select-next-loop
    } catch %{
        # restore initial selections if no valid filepath was found
        kak-restore-selections
        fail 'no existing file path found'
    }
}

# --------------------------------------
# filepath-select-previous

define-command -override -hidden filepath-select-previous-loop %{
    kak-clear-secondary-selections
    kak-reverse-search %opt{filepath_regex} # select the previous potential filepath string
    try %{
        filepath-fail-when-file-not-found
    } catch %{
        filepath-fail-when-existing-filepaths-not-found
        # if file contains filepaths to existing files, then recurse until finding one
        filepath-select-previous-loop
    }
}

define-command -override filepath-select-previous \
-docstring 'Select the previous existing file path in the file' %{
    try %{
        kak-save-selections
        filepath-select-previous-loop
    } catch %{
        # restore initial selections if no valid filepath was found
        kak-restore-selections
        fail 'no existing file path found'
    }
}
