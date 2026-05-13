# ------------------------------------------------------------------------------
# Integrations
#
# Each integration in this file depends on an external utility (rg, gh,
# kak-lsp, etc.) that must be installed separately on the host. The patterns
# below let the config load cleanly when some of those utilities are missing:
# a missing tool emits a debug message and the rest of the file keeps loading.
#
# --------------------------------------
# Standard pattern
#
# For each integration:
#   1. Define `init-<name>` as a top-level `-hidden` kak command containing
#      all the integration's setup (options, mappings, hooks, faces, ...).
#   2. Guard it with `require-cmd <program> init-<name>`. Trivial one-liners
#      may inline the body: `require-cmd <program> %{ ... }`.
#
# `require-cmd` (defined below) checks `command -v <program>` once at load
# time, evaluates the kak code if found, and otherwise emits a single
# `[integrations] <program>: not installed, skipping` debug line. Successful
# loads log `[integrations] <program>: initialized` so `:echo -debug` can be
# grepped to audit what loaded.
#
# Because `init-<name>` is a real kak command, you can re-run it
# interactively (`:init-rg`) after installing the missing tool, with no
# kakoune restart needed.
#
# --------------------------------------
# Problems this addresses
#
# - Fatal failures: a single missing binary aborting config load.
# - Silent gaps: without logging, you can't see what was skipped.
# - Boilerplate drift: each integration would otherwise reinvent the
#   shell-guard skeleton, with inconsistent variants accumulating over time.
# - Code-in-strings: kak code embedded in shell `printf` args loses syntax
#   highlighting and complicates quoting. Keeping setup in `init-<name>` at
#   the top level avoids this.
# - Hot-path overhead: hooks that fire frequently (e.g. `RegisterModified`)
#   must never call `command -v` on every fire. Resolve once at startup and
#   bake the result into the hook body.
#
# --------------------------------------
# Conventions
#
# - `init-<name>` is `-hidden` (off completion) but still invokable for
#   manual re-init.
# - Emit kak commands from shell blocks with `printf "%s\n"`, not `echo`
#   (`echo`'s `-n`/`-e` behavior is not portable).
# - Tag all debug messages with `[integrations]` so they're greppable.
# - `command -v` is a shell builtin: startup checks are free. Never call one
#   inside a frequently-fired hook.
#
# --------------------------------------
# Adding a new integration
#
# 1. Add a section comment header to keep the file scannable.
# 2. Define `init-<name>` with the setup body.
# 3. Add `require-cmd <program> init-<name>` immediately after.
#
# The standard pattern covers the common case, but specific integrations
# may need to deviate (multiple alternative backends, on-demand-only
# dependencies, transitively-reached dependencies, etc.). Adapt the
# conventions to fit the integration's actual constraints on a case-by-case
# basis. Before inventing a new approach, scan the existing integrations
# below for one that solves a similar problem and reuse its shape.

# ------------------------------------------------------------------------------
# require-cmd helper
#
# See the conventions described at the top of this file for usage.

define-command -hidden -override require-cmd -params 2 \
-docstring 'require-cmd <program> <kak-code>: evaluate <kak-code> only if <program> is on $PATH' %{
    evaluate-commands %sh{
        if command -v "$1" >/dev/null 2>&1; then
            printf "echo -debug '[integrations] %s: initializing...'\n" "$1"
            printf "%s\n" "$2"
            printf "echo -debug '[integrations] %s: initialized'\n" "$1"
        else
            printf "echo -debug '[integrations] %s: not installed, skipping'\n" "$1"
        fi
    }
}

# --------------------------------------
# System Clipboard
#
# Variant: multiple alternative backends + hot-path hook.
# - Supports clip.exe (WSL), wl-copy (Wayland), xsel (X11). The first
#   available is selected at startup. WSL paste uses powershell.exe
#   since clip.exe has no read counterpart.
# - To avoid a per-yank `command -v`, the resolved copy/paste shell
#   commands are stored in `clipboard_copy_cmd` / `clipboard_paste_cmd`
#   options. The hook and yank-system-clipboard `eval` those options.
# - Detection is bespoke, so this section invokes `init-clipboard`
#   directly rather than going through `require-cmd`. `init-clipboard`
#   mirrors the standard pattern as a single entry point: it calls
#   `set-clipboard-commands` for detection, then installs the hook,
#   yank-system-clipboard command, and user mappings. Nothing is
#   installed until `init-clipboard` runs, so calling
#   `:yank-system-clipboard` standalone fails with "no such command"
#   rather than silently producing an empty paste.

declare-option -hidden str clipboard_copy_cmd
declare-option -hidden str clipboard_paste_cmd

# Detect the available clipboard backend and store its copy/paste shell
# commands in the clipboard_*_cmd options. If no backend is available,
# the options remain empty.
define-command -hidden set-clipboard-commands %{
    evaluate-commands %sh{
        # Backend priority: WSL -> Wayland -> X11.
        if command -v clip.exe >/dev/null 2>&1 && command -v powershell.exe >/dev/null 2>&1; then
            backend='clip.exe / powershell.exe (WSL)'
            copy='printf %s "$kak_main_reg_dquote" | clip.exe'
            paste="powershell.exe -noprofile Get-Clipboard | tr -s '\r' '\n' | sed -z '\$ s/\n\$//'"
        elif command -v wl-copy >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
            backend='wl-copy / wl-paste (Wayland)'
            copy='printf %s "$kak_main_reg_dquote" | wl-copy --trim-newline'
            paste='wl-paste --no-newline'
        elif command -v xsel >/dev/null 2>&1; then
            backend='xsel (X11)'
            copy='printf %s "$kak_main_reg_dquote" | xsel --input --clipboard'
            paste='xsel --output --clipboard'
        else
            printf "echo -debug '[integrations] clipboard: no backend found'\n"
            exit 0
        fi

        printf "echo -debug '[integrations] clipboard: backend resolved (%s)'\n" "$backend"
        printf "set-option global clipboard_copy_cmd %%{%s}\n" "$copy"
        printf "set-option global clipboard_paste_cmd %%{%s}\n" "$paste"
    }
}

# Detect the backend, then install the integration: RegisterModified
# hook, yank-system-clipboard command, and user mappings for P/p/R.
# If no backend was detected, the hook and command are still installed
# but evaluate as silent no-ops (eval of empty option string).
define-command -hidden init-clipboard %{
    set-clipboard-commands

    # Save primary selection to system clipboard on all copy operations.
    hook global RegisterModified '"' %{ nop %sh{
        eval "$kak_opt_clipboard_copy_cmd"
    }}

    define-command -override yank-system-clipboard \
    -docstring 'save system clipboard to yank/paste register' %{
        evaluate-commands %sh{
            clipboard=$(eval "$kak_opt_clipboard_paste_cmd")
            printf "set-register dquote '%s'\n" "$clipboard"
        }
    }

    map global user P -docstring 'Paste system clipboard before cursor' \
    ":eval yank-system-clipboard<ret>P"
    map global user p -docstring 'Paste system clipboard after cursor' \
    ":eval yank-system-clipboard<ret>p"
    map global user R -docstring 'Replace selections with system clipboard' \
    ":eval yank-system-clipboard<ret>R"

    echo -debug '[integrations] clipboard: initialized'
}

init-clipboard

# --------------------------------------
# ripgrep (rg) / :grep command enhancements
#
# Trivial one-liner: uses the inline `require-cmd <prog> %{ ... }` form.
#
# Useful rg options:
# --smart-case : case insensitive if search is all lowercase, otherwise case sensitive
# --max-count 1 : only 1 matching line per file is returned
# --sort SORTBY : sort results in ascending order
# --sortr SORTBY : sort results in descending order
#   SORTBY : path, modified, accessed, created, none
# --word-regexp : only show matches surrounded by word boundaries

require-cmd rg %{ set-option global grepcmd 'rg --column --smart-case' }

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
