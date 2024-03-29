# This script provides commands & user mode bindings to quickly create code
# section comments.

# TODO:
# - [ ] Provide an option to apply a casing rule to section names.

# NOTE: Comment prefix is set by the comment_line option

declare-option str section_comment_delimiter "-"
declare-option int primary_section_width 80
declare-option int secondary_section_width 40

define-command -override -hidden insert-section-comment -params 2 \
-docstring "insert-section-comment <width> <section-name>: Inserts a section comment directly above the main cursor's position
<width>: width (in characters) of section divider
<section-name>: section name" \
%{
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

        keys_to_execute="O<esc>\"\"cPa <esc>$delimiter_length\"\"dpo<esc>\"\"cPa $SECTION_NAME<ret><esc>ll"
        printf "%s\n" "execute-keys \"$keys_to_execute\""
    }
}

define-command -override  primary-section-comment \
-docstring "creates a primary section comment using the section name obtained from a prompt" \
%{
    prompt "primary section name:" %{
        insert-section-comment %opt{primary_section_width} %val{text}
    }
}

define-command -override  secondary-section-comment \
-docstring "creates a secondary section comment using the section name obtained from a prompt" \
%{
    prompt "secondary section name:" %{
        insert-section-comment %opt{secondary_section_width} %val{text}
    }
}

define-command -override install-comment-mode-mappings \
-docstring "declare `comment-mode` user-mode & register default mappings" \
%{
    try %{ declare-user-mode comment-mode }
    map global comment-mode p ': primary-section-comment<ret>' -docstring 'Add a primary section comment above the current line'
    map global comment-mode s ': secondary-section-comment<ret>' -docstring 'Add a secondary section comment above the current line'
    map global comment-mode l ': comment-line<ret>' -docstring '(un)comment selected lines using line comments'
    map global comment-mode b ': comment-block<ret>' -docstring '(un)comment selections using block comments'
}
