# This script provides a custom 'search' user mode.
# TODO: wrap in a module if publishing as a plugin

declare-user-mode search

define-command search-mode-prompt \
-params 2 \
-docstring 'prompt for a search term to execute against the specified search command' \
%{
    evaluate-commands %sh{
        prompt_text=$1
        prompt_command=$2

        # Initialize the prompt with the content of the main selection
        # if it's longer than 1 character.
        if [ "$kak_selection_length" -gt "1" ]; then
            if [ "$prompt_command" = "literal-search" ]; then
                printf "%s\n" "execute-keys -save-regs '' \": set-register slash '$kak_selection'<ret>\""
            else
                printf "%s\n" "execute-keys -save-regs '' <a-*>"
            fi
            printf "%s %s\n" 'prompt -init "%reg{slash}"' "'$prompt_text' $prompt_command"
        else
            printf "%s\n" "prompt '$prompt_text' $prompt_command"
        fi
    }
}

# ------------------------------------------------------------------------------
# perform a case-insensitive search

define-command case-insensitive-search \
-hidden \
-docstring 'Execute a case-insensitive search using the given search term.' \
%{
    evaluate-commands %sh{
        search_expression="(?i)$kak_text"
        printf "%s\n" "execute-keys -save-regs '' \": set-register slash '$search_expression'<ret>\""
        printf "%s\n" "execute-keys ': exec /<ret>$search_expression<ret>'"
    }
}

map global search i ": search-mode-prompt 'case-insensitive search:' case-insensitive-search<ret>" \
-docstring 'perform a case-insensitive search'

# ------------------------------------------------------------------------------
# perform a literal (non-regex) search

define-command literal-search \
-hidden \
-docstring 'Execute a literal search using the given search term.' \
%{
    evaluate-commands %sh{
        search_expression="\Q$kak_text\E"
        printf "%s\n" "execute-keys -save-regs '' \": set-register slash '$search_expression'<ret>\""
        printf "%s\n" "execute-keys ': exec /<ret>$search_expression<ret>'"
    }
    # execute-keys ": exec /<ret>\Q%val{text}\E<ret>"
}

map global search l ": search-mode-prompt 'literal search:' literal-search<ret>" \
-docstring 'perform a literal search'
