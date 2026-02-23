# ------------------------------------------------------------------------------
# Specific Language Settings
# - Depends on configuration added in Global Language Settings section of the
#   main kakrc to provide the following commands:
#   - `enable-lint-mode-mappings`
#   - `enable-format-mode-mappings`

define-command -hidden set-format-with-prettier \
-docstring "Set format settings to use prettier" %{
    # NOTE: This option requires prettier:
    #       `npm install --save-dev --save-exact prettier`
    #         OR
    #       `yarn add --dev --exact prettier`
    set-option buffer formatcmd "npx prettier --stdin-filepath=%val{buffile}"
    hook buffer BufWritePre .* %{format-buffer}
    enable-format-mode-mappings
}

# --------------------------------------
# httpyac

source "~/.config/kak/highlighters/httpyac.kak"

# --------------------------------------
# Clojure

# hook groups starting with clojure- are all removed when leaving the filetype
# by kakoune's included clojure filetype script
hook global WinSetOption filetype=clojure -group clojure-fmt %{
    set-option window tabstop 2
    set-option window indentwidth 2

    # NOTE: This option requires clj-kondo to be installed.
    # See https://github.com/clj-kondo/clj-kondo/blob/master/doc/install.md#installation-script-macos-and-linux
    set-option buffer lintcmd 'clj-kondo --lint'

    # lint buffer on save
    # hook buffer BufWritePost .* %{lint-buffer}

    # Create lint-mode mappings for the window
    enable-lint-mode-mappings

    map global goto D "<esc>: lsp-declaration<ret>" -docstring 'go to declaration'

    # NOTE: This option requires kak-lsp to be set up for Clojure.
    hook buffer BufWritePre .* lsp-formatting-sync
}

# --------------------------------------
# JavaScript

hook global WinSetOption filetype=javascript %{
    set-option window tabstop 2
    set-option window indentwidth 2

    # Lint ----------------------------
    # NOTE: Linting is configured by the kak-jsts plugin (See below in file).

    # Set format settings to use prettier, create format-mode mappings
    set-format-with-prettier
}

# --------------------------------------
# HTML

hook global WinSetOption filetype=html %{
    set-option window tabstop 2
    set-option window indentwidth 2

    # TODO: https://www.html-tidy.org/
    # Lint ----------------------------
    # NOTE: This option requires :
    #       ``
    # set-option buffer lintcmd "tidy -e --gnu-emacs yes --quiet yes 2>&1"
    # lint buffer on save
    # hook buffer BufWritePost .* %{lint-buffer}
    # Create lint-mode mappings for the window
    # enable-lint-mode-mappings

    # Set format settings to use prettier, create format-mode mappings
    set-format-with-prettier
}

# --------------------------------------
# CSS

hook global WinSetOption filetype=css %{
    set-option window tabstop 4
    set-option window indentwidth 4

    # TODO: https://stylelint.io/
    # Lint ----------------------------
    # NOTE: This option requires :
    #       ``
    # set-option buffer lintcmd "stylelint --fix --stdin-filename='%val{buffile}'"
    # lint buffer on save
    # hook buffer BufWritePost .* %{lint-buffer}
    # Create lint-mode mappings for the window
    # enable-lint-mode-mappings

    # Set format settings to use prettier, create format-mode mappings
    set-format-with-prettier
}

# --------------------------------------
# JSON

hook global WinSetOption filetype=json %{
    set-option window tabstop 4
    set-option window indentwidth 4

    # Set format settings to use prettier, create format-mode mappings
    set-format-with-prettier
}

# --------------------------------------
# Python

hook global WinSetOption filetype=python %{
    # execute pytest for the current file
    source "%val{config}/custom/pytest.kak"
}
