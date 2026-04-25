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
# kakrc

# hook groups starting with kak- are all removed when leaving the filetype
hook global WinSetOption filetype=kak -group kak-custom %{
    set-option window tabstop 4
    set-option window indentwidth 4
}

# --------------------------------------
# sh

# hook groups starting with sh- are all removed when leaving the filetype
hook global WinSetOption filetype=sh -group sh-custom %{
    set-option window tabstop 4
    set-option window indentwidth 4
}

# --------------------------------------
# httpyac

source "~/.config/kak/highlighters/httpyac.kak"
# hook groups starting with httpyac- are all removed when leaving the filetype
hook global WinSetOption filetype=httpyac -group httpyac-custom %{
    set-option window tabstop 3
    set-option window indentwidth 3
}

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

    # Support for stdin/stdout usage added in `cljfmt` 0.10.3 & improved in 0.10.4
    # set-option buffer formatcmd 'cljfmt --remove-surrounding-whitespace fix -'
    # Not using --remove-surrounding-whitespace due to conflict with team member's formatting.
    # `--indents=indentation.clj` needed for cljs projects, if not all
    evaluate-commands %sh{
        if [ -f 'indentation.clj' ]; then
            printf "%s\n" "set-option buffer formatcmd 'cljfmt --indents=indentation.clj fix -'"
        else
            printf "%s\n" "set-option buffer formatcmd 'cljfmt fix -'"
        fi
    }

    # hook buffer BufWritePre .* %{format-buffer}
    # this block was copied from parinfer config
    evaluate-commands %sh{
        special_files_regex='.*\(project\.clj\|profiles\.clj\|\.edn\)$'
        fmt_on_write_group='clojure-fmt-on-write'
        # if the file DOES NOT match one of the special files, enable fmt-on-save
        if ! expr $kak_buffile : $special_files_regex 1>/dev/null; then
            # printf '%s\n' 'echo -debug "enabling fmt-on-write for buffer"'
            printf %s "hook -group $fmt_on_write_group buffer BufWritePre .* %{format-buffer}"
        # if the file DOES match one of the special files, disable fmt-on-save
        # TODO: I don't think I need this else
        else
            # printf '%s\n' 'echo -debug "disable fmt-on-write for buffer"'
            printf %s "remove-hooks buffer $fmt_on_write_group"
        fi
    }
    # Simple alternative formatting strategy:
    # - This option requires kak-lsp to be set up for Clojure.
    # - This is an easy solution, but slower than the native-compiled cljfmt.
    # hook buffer BufWritePre .* lsp-formatting-sync

    enable-format-mode-mappings

    # custom format-selections-pretty command for prettifying a selection
    define-command -override format-selections-pretty %{
        # save original formatcmd
        declare-option -hidden str formatcmd_original %opt{formatcmd}
        # set prettify formatcmd variant
        set-option buffer formatcmd \
        'cljfmt --remove-surrounding-whitespace \
                --split-keypairs-over-multiple-lines \
                fix -'
        # apply prettify formatting on selections
        format-selections
        # restore original formatcmd command
        set-option buffer formatcmd %opt{formatcmd_original}
    }
    map window format-mode p ':format-selections-pretty<ret>' -docstring 'pretty-format selections'
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
