# ------------------------------------------------------------------------------
# Plugins - Integrations
# > This file should be sourced after plug.kak is initialized in your kakrc
# > This file is for plugins that require external dependencies to be set up
# >  first in order to work.

# ------------------------------------------------------------------------------
# Configuration for the `fzf.kak` plugin
# https://github.com/andreyorst/fzf.kak

# NOTE: You must first install fzf for this to work
#       Ubuntu 20.04: `sudo apt install fzf`
plug "andreyorst/fzf.kak" config %{
    map global normal <c-p> ': fzf-mode<ret>'

    # open fzf file search when a new instance of Kakoune is first opened
    # hook -once global WinDisplay \*scratch\* %{
    #     require-module fzf
    #     require-module fzf-file
    #     fzf-file
    # }
} defer "fzf-file" %{
    # Change file search command to fd
    # NOTE: You must first install fd for this to work
    #       fd binary is fdfind in apt package
    #       alias to fd doesn't work here
    set-option global fzf_file_command 'fd --hidden --type f --exclude .git'

    set-option global fzf_highlight_command 'bat'
} defer "fzf-cd" %{
    set-option global fzf_cd_command 'fd --follow --hidden --type d --exclude .git'
} defer "fzf-grep" %{
    # Change grep search command to rg
    # NOTE: Your must first install ripgrep for this to work
    #       See https://github.com/BurntSushi/ripgrep#installation
    set-option global fzf_grep_command 'rg'
}

# ------------------------------------------------------------------------------
# Configuration for the `mru-files` plugin
# https://gitlab.com/kstr0k/mru-files.kak

plug 'https://gitlab.com/kstr0k/mru-files.kak.git' %{
    # optional customization: set these *before* plugin loads
    #set global mru_files_history %sh{echo "$HOME/.local/share/kak/mru.txt"}
} demand mru-files %{  # %{} needed even if empty
    # suggested mappings: *after* plugin loads
    # think "go alt[ernate]-f[iles]"
    map global goto <a-f> '<esc>: mru-files ' -docstring 'mru-files'
    map global goto <a-F> '<esc>: mru-files-related<ret>' -docstring 'mru-files-related'
}
# optional: enable kakhist (see kakhist/README.md)

# ------------------------------------------------------------------------------
# Configuration for the `luar` plugin
# https://github.com/gustavo-hms/luar

# plug "gustavo-hms/luar"

# ------------------------------------------------------------------------------
# Configuration for the `peneira` plugin
# https://github.com/gustavo-hms/peneira

# plug "gustavo-hms/peneira" demand luar %{
#     require-module peneira
# }

# ------------------------------------------------------------------------------
# Configuration for the `peneira-filters` plugin
# https://codeberg.org/mbauhardt/peneira-filters

# plug "https://codeberg.org/mbauhardt/peneira-filters" demand peneira %{
#     map global normal <c-p> ': peneira-filters-mode<ret>'
# } demand peneira-filters %{
#     # requires peneira, peneira-filters, & mru-files
#     map global peneira-filters m ': peneira-mru<ret>' -docstring 'List most recently used files'
# }

# ------------------------------------------------------------------------------
# Configuration for the `auto-pairs.kak` plugin
# https://github.com/alexherbo2/auto-pairs.kak

# NOTE: Dependent on kakoune.cr:
#       https://github.com/alexherbo2/kakoune.cr

plug "alexherbo2/auto-pairs.kak" config %{
    set-option global auto_pairs { }
    enable-auto-pairs
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-clojure` plugin
# https://github.com/jordan-yee/kakoune-clojure

# NOTE: This provides commands used by mappings in the `kakoune-repl-mode`
# config, as well as a custom `rep.kak` script, which requires `rep` to be
# installed (see further below).
# load-path "~/gitub/jordan-yee/kakoune-clojure"
plug "jordan-yee/kakoune-clojure" config %{
    rep-register-default-mappings
}

# ------------------------------------------------------------------------------
# Configuration for the `eraserhd/rep` plugin
# https://github.com/eraserhd/rep

# NOTE: You must first install the rep executable
# NOTE: In order to install using `make`, you may need a2x.
#       Ubuntu 20.04: `sudo apt install asciidoc-base`
# NOTE: A customized version of the rep.kak script was moved to the new
#       `kakoune-clojure` plugin, registered above.

# ------------------------------------------------------------------------------
# Configuration for the `kak-jsts` plugin
# https://github.com/schemar/kak-jsts

# NOTE: This plugin requires the following dependencies:
#       - eslint-formatter-kakoune
#         `npm i -g eslint-formatter-kakoune`
#       - jq

# plug "schemar/kak-jsts" config %{
#     hook global WinSetOption filetype=javascript %{
#         # lint buffer on save
#         hook buffer BufWritePost .* %{lint-buffer}
#         # Create lint-mode mappings for the window
#         enable-lint-mode-mappings
#     }
# }

# ------------------------------------------------------------------------------
# Configuration for the `parinfer-rust` plugin
# https://github.com/eraserhd/parinfer-rust

# NOTE: You must first install Rust and Clang for this to work
#       See https://www.rust-lang.org/tools/install
#       Ubuntu 20.04:
#         `sudo apt install rustc`
#         `sudo apt install clang`
# NOTE: Installing this might take a while.
#       Use L command on the plugin list to see compilation output.
plug "eraserhd/parinfer-rust" do %{
    cargo install --force --path .
    # Optionally add cargo clean line to the do block to clean plugin from build
    # files, thus making it load a bit faster:
    cargo clean
} config %{
    declare-user-mode parinfer
    map global parinfer s ': parinfer-disable-window<ret>: parinfer-enable-window -smart<ret>' \
    -docstring 'enable (smart)'
    map global parinfer i ': parinfer-disable-window<ret>: parinfer-enable-window -indent<ret>' \
    -docstring 'enable (preserve indentation, fix parens)<ret>'
    map global parinfer p ': parinfer-disable-window<ret>: parinfer-enable-window -paren<ret>' \
    -docstring 'enable (preserve parents, fix indentation)<ret>'
    map global parinfer d ': parinfer-disable-window<ret>' -docstring 'disable'

    hook global WinSetOption filetype=(clojure|lisp|scheme|racket) %{
        evaluate-commands %sh{
            # special_files_regex='.*\(project\.clj\|profiles\.clj\)$'
            special_files_regex='.*\(project\.clj\|profiles\.clj\|deps\.edn\|tests\.edn)$'
            # if the file DOES NOT match one of the special files, enable parinfer
            if ! expr $kak_buffile : $special_files_regex 1>/dev/null; then
                # printf '%s\n' 'echo -debug "enabling parinfer for window"'
                printf %s 'parinfer-enable-window -paren'
            # if the file DOES match one of the special files, disable parinfer
            else
                # printf '%s\n' 'echo -debug "disabling parinfer for window"'
                printf %s 'try %{ parinfer-disable-window }'
            fi
        }

        map window user i ': enter-user-mode parinfer<ret>' -docstring 'parinfer mode'
        map window normal u ': try %{ parinfer-disable-window }<ret>u'
        map window normal U ': try %{ parinfer-disable-window }<ret>U'
    }
}
