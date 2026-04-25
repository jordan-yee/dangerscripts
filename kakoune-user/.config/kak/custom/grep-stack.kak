# ------------------------------------------------------------------------------
# Fricitionless depth-first search with :grep and friends
# https://discuss.kakoune.com/t/fricitionless-depth-first-search-with-grep-and-friends/2152

# --------------------------------------
# Mappings

# example mappings to traverse search results:
# temporary dependency on kak-lsp for brevity
# map global normal <c-n> %{:lsp-next-location %opt{locations_stack_top}<ret>} -docstring 'lsp-next-location'
# map global normal <c-a-n> %{:lsp-previous-location %opt{locations_stack_top}<ret>} -docstring 'lsp-next-location'
map global normal <c-n> %{:lsp-next-location %opt{locations_stack_top}<ret>} -docstring 'jump-next'
map global normal <c-a-n> %{:lsp-previous-location %opt{locations_stack_top}<ret>} -docstring 'jump-previous'
map global normal <c-r> %{:locations-pop<ret>}
map global normal <a-g> %{:locations-goto-current<ret>} # <c-g> no longer bindable

# --------------------------------------
# Options

declare-option -hidden str-list locations_stack
declare-option -hidden str locations_stack_top
define-command -override locations-debug \
-docstring 'prints the values of locations options to the debug buffer' %{
    echo -debug "DEBUG LOCATIONS"
    echo -debug "locations_stack_top:"
    echo -debug %opt{locations_stack_top}
    echo -debug "locations_stack:"
    echo -debug %opt{locations_stack}
}

# --------------------------------------
# Hooks

# Clear hooks so they can be reset
try %{ remove-hooks global locations } catch %{ echo -debug "'locations' hook group not found" }

hook -group locations global GlobalSetOption locations_stack=.* %{
    set-option global locations_stack_top %sh{
        eval set -- $kak_quoted_opt_locations_stack
        for top; do :; done
        printf %s "$top"
    }
}

hook -group locations global WinDisplay \*(?:callees|callers|diagnostics|goto|find|grep|implementations|lint-output|references|symbols)\*(?:-\d+)? %{
    locations-push
}

# --------------------------------------
# Commands

define-command -override locations-push \
-docstring "push a new locations buffer onto the stack" %{
    evaluate-commands %sh{
        eval set -- $kak_quoted_opt_locations_stack
        if printf '%s\n' "$@" | grep -Fxq -- "$kak_bufname"; then
            # already in the stack
            printf "%s\n" "echo -debug 'locations buffer already in the stack'"
        else
            # rename to avoid conflict with *grep* etc.
            newname=$kak_bufname-$#
            echo "try %{ delete-buffer! $newname }"
            echo "rename-buffer $newname"
            echo "set-option -add global locations_stack %val{bufname}"
        fi
    }
}

define-command -override locations-pop \
-docstring "pop a locations buffer from the stack and return to previous location" %{
    evaluate-commands %sh{
        eval set -- $kak_quoted_opt_locations_stack
        if [ $# -lt 2 ]; then
        echo "fail locations-pop: no locations buffer to pop"
        fi
    }
    delete-buffer %opt{locations_stack_top}
    set-option -remove global locations_stack %opt{locations_stack_top}
    set-option global locations_stack_top %sh{
        eval set -- $kak_quoted_opt_locations_stack
        eval echo \"\$$#\"
    }
    try %{
        echo -debug "locations-pop: returning to last location"
        evaluate-commands -try-client %opt{jumpclient} %{
            buffer %opt{locations_stack_top}
            grep-jump
        }
    } catch %{
        echo -debug "locations-pop: failed to return to last location"
    }
}

define-command -override locations-clear \
-docstring "delete locations buffers" %{
    evaluate-commands %sh{
        eval set --  $kak_quoted_opt_locations_stack
        printf 'try %%{ delete-buffer %s }\n' "$@"
    }
    set-option global locations_stack
}

define-command -override locations-goto-current \
-docstring "go to the current locations buffer" %{
    try %{
        buffer %opt{locations_stack_top}
    } catch %{
        echo -debug "locations_stack_top not found"
    }
}
