# This file provides extended javascript functionality.

# ------------------------------------------------------------------------------
# Initialization

hook global WinSetOption filetype=javascript %{
    alias window alt-create js-create-alt

    hook -once -always window WinSetOption filetype=.* %{
        unalias window alt-create js-create-alt
    }
}

# ------------------------------------------------------------------------------
# Commands

define-command js-create-alt \
-docstring 'create an alt file for the current file' \
%{
    evaluate-commands %sh{
        # same path as kak_buffile, but with '.test' added before the filetype extension
        alt_buffile=$(echo "$kak_buffile" | sed -rn 's/^(.+)(\.jsx?)$/\1\.test\2/p')

        if [ -f "$kak_buffile" ]; then
            if [ -f "$alt_buffile"]; then
                printf "%s\n" "fail 'the alt file already exists'"
            else
                printf "%s\n" "e $alt_buffile"
            fi
        else
            printf "%s\n" "fail 'the current file doesn''t exist; save it first'"
        fi
    }
}

define-command js-insert-arrow-function \
-docstring 'insert an ES6 arrow function `() => {}`' \
%{
    # TODO: Figure out how to properly finish in insert mode
    # execute-keys 'i() => {}<esc>h'
    # execute-keys -with-hooks 'i'

    # NOTE: The above relies on hooks from other plugins to insert the closing paren & brace.
    execute-keys -with-hooks 'i(<esc>li => {' # closing chars for m: })
}

# ------------------------------------------------------------------------------
# javascript User Mode

declare-user-mode javascript

map global javascript a ': js-insert-arrow-function<ret>' -docstring 'insert an ES6 arrow function `() => {}`'
