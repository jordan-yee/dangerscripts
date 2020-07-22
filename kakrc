# -----------------------------------------------------------------------------
# basic configuration

#colorscheme grubbox

# show line numbers
add-highlighter global/ number-lines -relative -hlcursor -min-digits 3

# show max-width helper line
set-option global autowrap_column 95
# TODO: Make this a less glaring style.
# add-highlighter global/ column '%opt{autowrap_column}' default,white

# soft-wrap lines to always be visible within the terminal
add-highlighter global/ wrap

# show matching brackets
add-highlighter global/ show-matching

# show trailing whitespace - not working, may be WT issue
add-highlighter global/trailing regex '[ \t\f\v]+$' 0:Whitespace

# highlight special comment words
add-highlighter global/ regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb

# set default indentation width
set-option global indentwidth 4
set-option global tabstop 4

# use rg for the grep command
set-option global grepcmd 'rg --column'

# -----------------------------------------------------------------------------
# mappings

# use space for user mode leader key
# ----------------------------------

# rebind <space>
map global normal <space> , -docstring 'leader'
# rebind <backspace> to replace the old function of <space>
map global normal <backspace> <space> -docstring 'remove all sels except main'
map global normal <a-backspace> <a-space> -docstring 'remove main sel'

# extend view mappings
# --------------------

# TODO: Make these bindings appear in the comma-delimmited list of keys that
#       perform the same action.
map global view K t -docstring 'cursor on top'
map global view J b -docstring 'cursor on bottom'

# perform a literal (non-regex) search in user mode
# -------------------------------------------------

map global user / ':exec /<ret>\Q\E<left><left>' -docstring 'literal search'

# paste from Windows file
# -----------------------
# NOTE: I recommend openning this file in an editor in Windows that can auto-convert line endings.
#       notepad++ has this option

map global user P '!cat /mnt/c/Users/jyee_/clipboard.txt<ret>' -docstring 'paste from clipboard.txt (before)'
map global user p '<a-!>cat /mnt/c/Users/jyee_/clipboard.txt<ret>' -docstring 'paste from clipboard.txt (after)'

# -----------------------------------------------------------------------------
# hooks

# jk to escape
# ------------

hook global InsertChar k %{ try %{
    exec -draft hH <a-k>jk<ret> d
    exec <esc>
}}

# tab complete
# ------------

hook global InsertCompletionShow .* %{
    try %{
        execute-keys -draft 'h<a-K>\h<ret>'
        map window insert <tab> <c-n>
        map window insert <s-tab> <c-p>
    }
}

hook global InsertCompletionHide .* %{
    unmap window insert <tab> <c-n>
    unmap window insert <s-tab> <c-p>
}

# copy to Windows clipboard
# -------------------------

hook global NormalKey y|d|c %{ nop %sh{
    printf %s "$kak_main_reg_dquote" | clip.exe
}}

# add matches for sh filetype
# ---------------------------

hook global BufCreate .*\.(conf) %{
    set-option buffer filetype sh
}

# change cursor color in insert mode
# ----------------------------------
# TODO: This should optimally be be based on the theme.
# https://discuss.kakoune.com/t/changing-the-cursor-colour-in-insert-mode/394

# hook global ModeChange insert:.* %{
#   set-face global PrimaryCursor rgb:ffffff,rgb:000000+F
# }

# hook global ModeChange .*:insert %{
#   set-face global PrimaryCursor rgb:ffffff,rgb:008800+F
# }

# set clojure-specific settings
# -----------------------------
hook global WinSetOption filetype=clojure %{
    set-option global indentwidth 2
    set-option global tabstop 2
}

# clj-kondo - linter for clojure
# ------------------------------

hook global WinSetOption filetype=clojure %{
    set-option window lintcmd 'clj-kondo --lint'
}

# -----------------------------------------------------------------------------
# PLUGINS - Basic Essential

# load plugin manger
# NOTE: You must first clone the git repo for this to work:
#       `mkdir -p ~/.config/kak/plugins/`
#       `git clone https://github.com/andreyorst/plug.kak.git ~/.config/kak/plugins/plug.kak`
# ------------------
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload config %{ }

# mystical tutor colorscheme
# --------------------------
# Modified version of https://github.com/caksoylar/kakoune-mysticaltutor
# - Original theme uses bold to indicate matching characters, but bold
#   isn't supported on Windows Terminal (7/13/2020).

plug "jordan-yee/kakoune-mysticaltutor" theme %{ colorscheme mysticaltutor }
plug "jordan-yee/kakoune-mysticaltutor-powerline" defer powerline %{
    powerline-theme mysticaltutor
}

# convert tabs to spaces
# ----------------------
plug "andreyorst/smarttab.kak" defer smarttab %{
    set-option global softtabstop %opt{tabstop}
}

# change case of selection
# ------------------------

plug "https://gitlab.com/FlyingWombat/case.kak" config %{
    map global normal '`' ': enter-user-mode case<ret>'
}

# prelude - scripting helper - dependecy of other plugins
# -------------------------------------------------------

plug "alexherbo2/prelude.kak"

# auto-insert matching characters
# -------------------------------
# Dependent on prelude plugin:
# https://github.com/alexherbo2/prelude.kak

plug "alexherbo2/auto-pairs.kak"

# manage surrounding characters
# -----------------------------

plug "h-youhei/kakoune-surround" config %{
    declare-user-mode surround
    map global surround s ':surround<ret>' -docstring 'surround'
    map global surround c ':change-surround<ret>' -docstring 'change'
    map global surround d ':delete-surround<ret>' -docstring 'delete'
    map global surround t ':select-surrounding-tag<ret>' -docstring 'select tag'
    map global user s ':enter-user-mode surround<ret>' -docstring 'surround mode'
}

# enhanced text-object selection
# ------------------------------
# NOTE: Vertical selections require the kakoune-vertical-selection plugin.

plug 'delapouite/kakoune-text-objects'

# vertical selection of matching text
# -----------------------------------
# NOTE: This plugin is used by the kakound-text-objects plugin.

plug 'occivink/kakoune-vertical-selection' config %{
    map global user v     ': vertical-selection-down<ret>' -docstring 'vertical selection down'
    map global user <a-v> ': vertical-selection-up<ret>' -docstring 'vertical selection up'
    map global user V     ': vertical-selection-up-and-down<ret>' -docstring 'vertical selection both'
}

# shortcuts for common selection commands
# ---------------------------------------

plug 'delapouite/kakoune-auto-percent'

# easier navigation between buffers
# ---------------------------------

plug 'delapouite/kakoune-buffers' config %{
    # Remap macro record/playback bindings
    # NOTE: @/<a-@> converts spaces <=> tabs by default
    #       I'm not setting up a replacement binding for it because I don't use it.
    #       It might not work anyway with the smarttab plugin.
    map global normal <a-@> q
    map global normal @ Q

    # Remap select-word-on-left bindings
    map global normal q b
    map global normal Q B
    map global normal <a-q> <a-b>
    map global normal <a-Q> <a-B>

    # Map bindings for buffer modes from plugin
    map global normal b ': enter-buffers-mode<ret>' -docstring 'buffers'
    map global normal B ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'
}

# git mode
# --------

plug "jordan-yee/kakoune-git-mode"

# -----------------------------------------------------------------------------
# PLUGINS - Advanced

# improved status bar
# -------------------

# NOTE: You may need to use a powerline font for things to look right.
plug "andreyorst/powerline.kak" defer powerline %{
    set-option global powerline_shorten_bufname short
    # Using custom powerline theme
    powerline-theme mysticaltutor
} config %{
    powerline-start

    # From a version of the plugin README not on GitHub:
    # Note that as settings are window dependent new window will use default
    # separator, which is triangle. To prevent this either use separate hook
    # global WinCreate .* %{ powerline-separator triangle } that will be applied
    # to all new windows, or modify powerline_separator and
    # powerline_separator_thin global options to your liking.
    hook global WinCreate .* %{
        powerline-separator none
    }
}

# fuzzy finder
# ------------
# TODO: Use <c-j/k> to navigate results list.

# NOTE: You must first install fzf for this to work
#       Ubuntu 20.04: `sudo apt install fzf`
plug "andreyorst/fzf.kak" defer fzf %{
    # Change file search command to fd
    # NOTE: You must first install fd for this to work
    #       fd binary is fdfind in apt package
    #       alias to fd doesn't work here
    set-option global fzf_file_command 'fdfind --hidden --exclude .git'
    set-option global fzf_cd_command 'fdfind --follow --hidden --exclude .git'

    # Change grep search command to rg
    # NOTE: Your must first install ripgrep for this to work
    #       See https://github.com/BurntSushi/ripgrep#installation
    set-option global fzf_grep_command 'rg'

    # To discover other options or access command docs, view auto-complete
    # results of `:set-option global fzf` command.
} config %{
    map global normal <c-p> ': fzf-mode<ret>'
}

# find and replace in open buffers
# --------------------------------

plug "occivink/kakoune-find"


# parinfer - lisp parenthesis management
# --------------------------------------

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
    hook global WinSetOption filetype=(clojure|lisp|scheme|racket) %{
        parinfer-enable-window -smart
    }
}

# rep - execute clojure code in a repl
# ------------------------------------

# NOTE: You must first install the rep executable
#       See https://github.com/eraserhd/rep/blob/develop/rc/rep.kak
#       Recommended installation procedure:
#        1) Download binary from releases tab in GitHub.
#        2) cp the binary to /usr/local/bin/
#        3) cp the manual to /usr/local/share/man/man1/
# This plugin configuration installs the repo's /rc/rep.kak to integrate with
# the external executable.
plug "eraserhd/rep" tag "v0.1.2" subset %{
    rep.kak
}

# kak-lsp - kakoune language server protocol client
# -------------------------------------------------

# NOTE: You must first install cargo for this to work
#       See https://github.com/ul/kak-lsp
plug "ul/kak-lsp" tag "v8.0.0" do %{
    cargo build --release --locked
    cargo install --force --path .
} config %{
    set-option global lsp_completion_trigger "execute-keys 'h<a-h><a-k>\S[^\h\n,=;*(){}\[\]]\z<ret>'"

    hook global WinSetOption filetype=(c|cpp|clojure) %{
        map window user "l" ": enter-user-mode lsp<ret>" -docstring "LSP mode"
        lsp-enable-window
        set-option window lsp_hover_anchor true
        set-face window DiagnosticError default+u
        set-face window DiagnosticWarning default+u
    }

    hook global KakEnd .* lsp-exit
}
