# This script provides commands & user mode bindings to quickly create code
# section comments.

# TODO: Provide an option to apply a casing rule to section names.

# NOTE: Comment prefix is set by the comment_line option

declare-option str section_comment_delimiter "-"
declare-option int primary_section_width 80
declare-option int secondary_section_width 40

# Inserts a section comment directly above the main cursor's position
# Argument 1
# - width (in characters) of section divider
# Argument 2
# - section name
define-command -hidden insert-section-comment -params 2 %{
    # This requires the comment.kak rc script that ships with Kakoune to be loaded
    set-register c %opt{comment_line}
    set-register d %opt{section_comment_delimiter}

    evaluate-commands %sh{
        WIDTH=$1
        SECTION_NAME=$2

        comment_line_length=${#kak_opt_comment_line}
        # Length of the line comment char(s) plus a space
        prefix_length=`expr $comment_line_length + 1`
        delimiter_length=`expr $WIDTH - $prefix_length`

        keys_to_execute="O<esc>\"\"cPi <esc>$delimiter_length\"\"dPi<ret><esc>\"\"cPi $SECTION_NAME<ret><esc>l"
        printf "%s\n" "execute-keys \"$keys_to_execute\""
    }
}

define-command primary-section-comment \
-docstring "creates a primary section comment using the section name obtained from a prompt" \
%{
    prompt "primary section name:" %{
        insert-section-comment %opt{primary_section_width} %val{text}
    }
}

define-command secondary-section-comment \
-docstring "creates a secondary section comment using the section name obtained from a prompt" \
%{
    prompt "secondary section name:" %{
        insert-section-comment %opt{secondary_section_width} %val{text}
    }
}

define-command install-comment-mode-mappings %{
    declare-user-mode comment-mode

    map global user c ': enter-user-mode comment-mode<ret>' -docstring 'comment mode'

    map global comment-mode p ': primary-section-comment<ret>' -docstring 'Add a primary section comment above the current line'
    map global comment-mode s ': secondary-section-comment<ret>' -docstring 'Add a secondary section comment above the current line'
    map global comment-mode l ': comment-line<ret>' -docstring '(un)comment selected lines using line comments'
    map global comment-mode b ': comment-block<ret>' -docstring '(un)comment selections using block comments'
}
