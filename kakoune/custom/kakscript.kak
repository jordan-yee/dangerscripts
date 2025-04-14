# ------------------------------------------------------------------------------
# Commands for scripting basic kakoune functionality more cleanly.

# Usage Instructions:
# Add the following snippet to the top of scripts that use this module:
# ```
# NOTE: Ensure the module is source'd ahead of this one:
# # source "%val{config}/custom/kakscript.kak"
# require-module kakscript # exposes commands prefixed with `kak-`
# ```

# TODO:
# - [X] Wrap in a module for use by other scripts/plugins
# - [ ] Define rules for extending the API in a consistent manner
# - [ ] Define low-level vs higher-level API layers if needed

provide-module -override kakscript %[

define-command -override -hidden -params 1 kak-search \
-docstring 'select next match after each selection' %{
    execute-keys "/%arg{1}<ret>"
}

define-command -override -hidden -params 1 kak-reverse-search \
-docstring 'select previous match before each selection' %{
    execute-keys "<a-/>%arg{1}<ret>"
}

define-command -override -hidden kak-clear-secondary-selections \
-docstring 'clear selections to only keep the main one' %{
    execute-keys ,
}

define-command -override -hidden kak-save-selections \
-docstring 'save selections to the register' %{
    execute-keys -save-regs '' Z
}

define-command -override -hidden kak-restore-selections \
-docstring 'restore selections from the register' %{
    execute-keys z
}

define-command -override -hidden kak-select-all \
-docstring 'select whole buffer' %{
    execute-keys '%'
}

define-command -override -hidden kak-select-to-end \
-docstring 'select to the end of the buffer' %{
    execute-keys '<semicolon>Ge'
}

define-command -override -hidden kak-select-to-top \
-docstring 'select to the top (beginning) of the buffer' %{
    execute-keys '<semicolon>Gg'
}


define-command -override -hidden -params 1 kak-select-regex \
-docstring 'create a selection for each match of the given regex' %{
    execute-keys "s%arg{1}<ret>"
}

] # end provide-module
