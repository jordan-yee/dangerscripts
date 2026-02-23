# ------------------------------------------------------------------------------
# Integrations

### Example shell block to check existence of dependency. ###
# evaluate-commands %sh{
#     if command -v parinfer-rust >/dev/null 2>&1; then
#         printf "%s\n" "echo -debug 'parinfer-rust is installed: initializing...'"
#         printf "%s\n" "init-parinfer-rust"
#         printf "%s\n" "echo -debug 'parinfer-rust config initialized.'"
#     else
#         printf "%s\n" "echo -debug 'parinfer-rust is not installed: skipping initialization.'"
#     fi
# }

# --------------------------------------
# System Clipboard

# Save primary selection to system clipboard on all copy operations.
hook global RegisterModified '"' %{ nop %sh{
    # Copy to Ubuntu clipboard
    # NOTE: This system clipboard integration requires xsel to be installed.
    #       `apt install -y xsel`
    #printf %s "$kak_main_reg_dquote" | xsel --input --clipboard

    # Copy to Sway/Wayland clipboard (NOTE: needs improvements)
    #( wl-copy --trim-newline $kak_main_reg_dquote & ) 2>/dev/null

    # Copy to tmux clipboard
    #tmux set-buffer -- "$kak_main_reg_dquote"

    # Copy to Windows clipboard from WSL
    printf %s "$kak_main_reg_dquote" | clip.exe
}}

define-command yank-system-clipboard \
-docstring 'save system clipboard to yank/paste register' %{
    evaluate-commands %sh{
        windows_clipboard=$(powershell.exe -noprofile Get-Clipboard | tr -s '\r' '\n' | sed -z '$ s/\n$//')
        printf "set-register dquote '%s'\n" "$windows_clipboard"
    }
}

# paste from system clipboard
# map global user P '!xsel --output --clipboard<ret>' -docstring 'Paste system clipboard before cursor'
# map global user p '<a-!>xsel --output --clipboard<ret>' -docstring 'Paste system clipboard after cursor'
map global user P -docstring 'Paste system clipboard before cursor' \
":eval yank-system-clipboard<ret>P"
# "!powershell.exe -noprofile Get-Clipboard | tr -s '\r' '\n' | sed -z '$ s/\n$//'<ret>"
map global user p -docstring 'Paste system clipboard after cursor' \
":eval yank-system-clipboard<ret>p"
# "<a-!>powershell.exe -noprofile Get-Clipboard | tr -s '\r' '\n' | sed -z '$ s/\n$//'<ret>"
map global user R -docstring 'Replace selections with system clipboard' \
":eval yank-system-clipboard<ret>R"

# Wayland / Sway wl-copy/paste integration
# map global user P '!wl-paste --no-newline | dos2unix<ret>' -docstring 'Paste system clipboard before cursor'
# map global user p '<a-!>wl-paste --no-newline | dos2unix<ret>' -docstring 'Paste system clipboard after cursor'
# map global user R '|wl-paste --no-newline | dos2unix<ret>' -docstring 'Replace selections with system clipboard'

# NOTE: Wayland (WSL) / Windows integration is setup externally

# --------------------------------------
# ripgrep (rg) / :grep command enhancements
# NOTE: You must install ripgrep for this functionality to work.

# Useful rg options:
# --smart-case : case insensitive if search is all lowercase, otherwise case sensitive
# --max-count 1 : only 1 matching line per file is returned
# --sort SORTBY : sort results in ascending order
# --sortr SORTBY : sort results in descending order
#   SORTBY : path, modified, accessed, created, none
# --word-regexp : only show matches surrounded by word boundaries

set-option global grepcmd 'rg --column --smart-case'

# --------------------------------------
# kakoune.cr
# See https://github.com/alexherbo2/kakoune.cr

evaluate-commands %sh{
    kcr init kakoune
}

# --------------------------------------
# gh (GitHub CLI)

define-command -override gh-browse \
-docstring 'Open file to current line in GitHub in your browser' %{
    # TODO: check
    # - existence of gh command
    # - that we're in a github repo
    echo %sh{
        project_root=$(PWD) # assuming kak's working directory is project root
        gh browse "$kak_reg_percent:$kak_cursor_line"
        # printf "gh browse %s\n" "$kak_reg_percent:$kak_cursor_line"
        printf "Opening current file in GitHub...\n"
    }
}

# ------------------------------------------------------------------------------
# kakoune-lsp
# - https://github.com/kakoune-lsp/kakoune-lsp
# - https://github.com/kakoune-lsp/kakoune-lsp/releases
# - LSP Servers:
#   - [clojure-lsp](https://clojure-lsp.io/installation/#script)

evaluate-commands %sh{kak-lsp}

# --------------------------------------
# General LSP Configuration

# general configuration is wrapped in this command to make it easier to enable/disable it
define-command -hidden init-kak-lsp %{
    # Documentation on available options can be seen here:
    # https://github.com/kak-lsp/kak-lsp#configuring-kakoune

    # Enable to get more verbose logs for debugging:
    # set-option global lsp_debug true

    set-option global lsp_completion_trigger "execute-keys 'h<a-h><a-k>\S[^\h\n,=;*(){}\[\]]\z<ret>'"
    set-option global lsp_auto_highlight_references true
    set-option global lsp_auto_show_code_actions true
    set-option global lsp_timeout 0 # disable lsp timeout
    set-option global lsp_file_watch_support true
    set-option global lsp_hover_anchor true

    map global user "l" ": enter-user-mode lsp<ret>" -docstring "LSP mode"

    # Diagnostics
    map global lsp "n" ": lsp-find-error --include-warnings<ret>" \
    -docstring "find next diagnostic"
    map global lsp "p" ": lsp-find-error --previous --include-warnings<ret>" \
    -docstring "find previous diagnostic"

    # Snippets
    # TODO: See parinfer issue in Clojure config below
    # map global insert <tab> '<a-;>: try %{ lsp-snippets-select-next-placeholders } catch %{ execute-keys -with-hooks <lt>tab> }<ret>' \
    # -docstring 'Select next snippet placeholder'

    # Overridden to use the configured `formatcmd`
    # For Clojure, the intent is to use the standalone graalvm cljfmt binary:
    # https://github.com/weavejester/cljfmt?tab=readme-ov-file#usage
    map global lsp f "<esc>: format-buffer<ret>" -docstring 'format contents of the buffer'

    set-face global DiagnosticError default+u
    set-face global DiagnosticWarning default+u

    # Markdown rendering in info box:
    # https://github.com/kak-lsp/kak-lsp
    # By default all of these faces use `Information`
    # I updated some of them using faces from the mysticaltutor theme, so
    # make sure that's installed/loaded first.
    face global InfoDefault               Information
    face global InfoBlock                 block
    face global InfoBlockQuote            block
    face global InfoBullet                bullet
    face global InfoHeader                header
    face global InfoLink                  link
    face global InfoLinkMono              mono
    face global InfoMono                  mono
    face global InfoRule                  Information
    face global InfoDiagnosticError       Error
    face global InfoDiagnosticHint        Information
    face global InfoDiagnosticInformation Information
    face global InfoDiagnosticWarning     Information
}
init-kak-lsp

# --------------------------------------
# Clojure

# Clojure Server Config - https://clojure-lsp.io/installation/#script
hook -group lsp-filetype-clojure global BufSetOption filetype=(clojure) %{
    set-option buffer lsp_servers %{
        [clojure-lsp]
        root_globs = ["deps.edn", "project.clj", ".git", ".hg"]
        settings_section = "_"
        [clojure-lsp.settings._]
        # See https://clojure-lsp.io/settings/#all-settings
        # source-paths-ignore-regex = ["resources.*", "target.*"]
    }
}

# Clojure Filtetype Config
hook global WinSetOption filetype=(clojure) %{
    # TODO: disable parinfer only when inserting a snippet completion
    # hook -once global InsertCompletionHide .* parinfer-disable-window

    # Select Clojure def's
    map global object e '<a-semicolon>lsp-object Function Variable<ret>' \
    -docstring 'LSP Function or Variable (def expressions)'

    # Goto ns alias in require
    map global goto D "<esc>: lsp-declaration<ret>" -docstring 'go to declaration'
    map global goto <a-d> "<esc>: newv lsp-definition<ret>" -docstring 'go to defintion in vsplit'
    map global goto <a-D> "<esc>: newh lsp-definition<ret>" -docstring 'go to defintion in hsplit'

    lsp-enable-window

    lsp-auto-signature-help-enable
    lsp-inlay-hints-enable global

    # Debugging kak-lsp:
    #
    # View debug info in a dedicated terminal:
    # 1. Run kak-lsp in another terminal (up to 4 v's):
    #    `kak-lsp -s main -vvv`
    # 2. Start kakoune with:
    #    `kak -s main`
    # 3. Disable the exit hook (bottom of this config block) if you want.
    #
    # Save debug info to a log file:
    # 1. Enable the following command to enable logging:
    # set-option global lsp_cmd "kak-lsp -s %val{session} -vvv --log /tmp/kak-lsp.log"
    #    - This should come after `lsp-enable-window`
    #    - Default lsp_cmd: `kak-lsp -s %val{session}`
}
