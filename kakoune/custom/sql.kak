define-command -override hug-sql-select-keywords \
-docstring 'example quick-dev command' %{
    execute-keys 's(?!-)\b(select|from|where|inner|outer|left|join|as|on|in|is|null|and|or|not|order|group|by)(?!-)\b<ret>'
}

define-command -override hug-sql-select-parameters \
-docstring 'example quick-dev command' %{
    execute-keys 's:(\w|-)+<ret>'
}

define-command -override init-hug-sql-mode \
-docstring 'utilities for working with HugSQL' %{
    try %{ declare-user-mode hug-sql-mode }
    # Ensure old key mappings don't stick around if you change mapped keys.
    unmap global hug-sql-mode
}

define-command -override register-default-hug-sql-mode-mappings \
-docstring 'register default mappings for hug-sql-mode' %{
    map global hug-sql-mode k ": hug-sql-select-keywords<ret>" \
    -docstring 'select SQL keywords'
    map global hug-sql-mode p ": hug-sql-select-parameters<ret>" \
    -docstring 'select HugSQL parameters (Clojure keywords)'
}

# You'd call these from your kakrc when finished quick-dev'ing:
init-hug-sql-mode
register-default-hug-sql-mode-mappings
map global user H ": enter-user-mode hug-sql-mode<ret>" \
-docstring 'Activate hug-sql-mode'
