# ------------------------------------------------------------------------------
# Plugins - Standalone
# > This file should be sourced after plug.kak is initialized in your kakrc
# > This file is for plugins that don't have any external dependencies, so they
# >  should all work out-of-the-box.

# ------------------------------------------------------------------------------
# Configuration for the `powerline.kak` plugin
# https://github.com/andreyorst/powerline.kak

# NOTE: Powerline module definition (requires the powerline plugin)
hook global ModuleLoaded powerline %{ require-module powerline_parinfer }
provide-module powerline_parinfer %{
    # NOTE: Here I'm relying on the option: `parinfer_current_mode_modeline`
    # This is managed by manual changes to the parinfer rc script, which only
    # exist local at the time of writing this comment.

    declare-option -hidden bool powerline_module_parinfer true
    set-option -add global powerline_modules 'parinfer'

    define-command -hidden powerline-parinfer %{
        evaluate-commands %sh{
            default=$kak_opt_powerline_base_bg
            next_bg=$kak_opt_powerline_next_bg
            normal=$kak_opt_powerline_separator
            thin=$kak_opt_powerline_separator_thin
            if [ "$kak_opt_powerline_module_parinfer" = "true" ]; then
                fg=$kak_opt_powerline_color10
                bg=$kak_opt_powerline_color11
                if [ ! -z "$kak_opt_parinfer_current_mode" ]; then
                    [ "$next_bg" = "$bg" ] && separator="{$fg,$bg}$thin" || separator="{$bg,${next_bg:-$default}@powerline_base}$normal"
                    echo "set-option -add global powerlinefmt %{$separator{$fg,$bg} %opt{powerline_parinfer_current_mode} }"
                    echo "set-option global powerline_next_bg $bg"
                fi
            fi
        }
    }

    declare-option -hidden str powerline_parinfer_current_mode
    define-command -hidden powerline-update-parinfer-current-mode %{
        set-option buffer powerline_parinfer_current_mode %sh{
            current_mode=$kak_opt_parinfer_current_mode_modeline
            enabled=$kak_opt_parinfer_enabled
            if [ -z "$current_mode" ] || [ "$enabled" = "false" ]; then
                current_mode="off"
            fi
            printf "%s\n" "(${current_mode})"
        }
    }

    define-command -hidden powerline-parinfer-setup-hooks %{
        remove-hooks global powerline-parinfer
        evaluate-commands %sh{
            if [ "$kak_opt_powerline_module_parinfer" = "true" ]; then
                printf "%s\n" "hook -group powerline-parinfer global WinDisplay .* %{ powerline-update-parinfer-current-mode }"
                printf "%s\n" "hook -group powerline-parinfer global WinSetOption parinfer_current_mode_modeline=.* %{ powerline-update-parinfer-current-mode }"
                # somewhat works
                # printf "%s\n" "hook -group powerline-parinfer global ModeChange .* %{ powerline-update-parinfer-current-mode }"
            fi
        }
    }

    define-command -hidden powerline-toggle-parinfer -params ..1 %{
        evaluate-commands %sh{
            [ "$kak_opt_powerline_module_parinfer" = "true" ] && value=false || value=true
            if [ -n "$1" ]; then
                [ "$1" = "on" ] && value=true || value=false
            fi
            echo "set-option global powerline_module_parinfer $value"
        }
    }
}

plug "andreyorst/powerline.kak" defer powerline %{
    set-option global powerline_ignore_warnings true
    # default: powerline-format global 'git bufname line_column mode_info filetype client session position'
    powerline-format global 'git bufname line_column mode_info filetype parinfer client session position'
    powerline-separator global none
} defer powerline_bufname %{
    set-option global powerline_shorten_bufname short
} config %{
    powerline-start
}

# ------------------------------------------------------------------------------
# Configuration for the `smarttab.kak` plugin
# https://github.com/andreyorst/smarttab.kak

# noexpandtab: use tab character to indent and align
# smarttab:    use tab character to indent and space to align
# expandtab:   use space character to indent and align

plug "andreyorst/smarttab.kak" defer smarttab %{
    # set how many spaces to delete when pressing <backspace>
    set-option global softtabstop %opt{tabstop}
} config %{
    # these languages will use `expandtab' behavior
    hook global WinSetOption filetype=(rust|markdown|kak|lisp|scheme|sh|perl|javascript|python|yaml|sql) expandtab
    # these languages will use `noexpandtab' behavior
    hook global WinSetOption filetype=(makefile|gas|go) noexpandtab
    # these languages will use `smarttab' behavior
    hook global WinSetOption filetype=(c|cpp) smarttab
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-mysticaltutor` plugin
# https://github.com/caksoylar/kakoune-mysticaltutor

plug "caksoylar/kakoune-mysticaltutor" theme config %{
    colorscheme mysticaltutor
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-mysticaltutor-powerline` plugin
# https://github.com/jordan-yee/kakoune-mysticaltutor-powerline

# NOTE: Make sure this comes after the powerline configuration

plug "jordan-yee/kakoune-mysticaltutor-powerline" defer powerline_mysticaltutor %{
    powerline-theme mysticaltutor
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-git-mode` plugin
# https://github.com/jordan-yee/kakoune-git-mode

plug "jordan-yee/kakoune-git-mode" config %{
    set-option global git_mode_use_structured_quick_commit true
    declare-git-mode
    map global user g ': enter-user-mode git<ret>' -docstring "git mode"
    map global git o ': tmux-terminal-window lazygit<ret>' -docstring "open lazygit in new window"
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-plugin-quick-dev` plugin
# https://github.com/jordan-yee/kakoune-plugin-quick-dev

# load-path "/home/jordan/github/jordan-yee/kakoune-plugin-quick-dev/"
plug "jordan-yee/kakoune-plugin-quick-dev" config %{
  quick-dev-mode-init
  quick-dev-register-default-mappings
  map global user q ': enter-user-mode quick-dev<ret>' -docstring 'quick-dev mode'
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-repl-mode` plugin
# https://github.com/jordan-yee/kakoune-repl-mode

# load-path "~/github/jordan-yee/kakoune-repl-mode/"
plug "jordan-yee/kakoune-repl-mode" config %{
    require-module repl-mode
    map global user r ': enter-user-mode repl<ret>' -docstring "repl mode"
    repl-mode-register-default-mappings

    declare-user-mode repl-commands
    map global repl-commands c ': clojure-repl-command<ret>' -docstring "Prompt for a REPL command to evaluate on the current selection"
    map global repl-commands l ': clojure-repl-command dlet<ret>' -docstring "dlet"
    # map global repl-commands t ': clojure-repl-command clojure.test/run-test<ret>' -docstring "run-test"
    map global repl-commands t ': clojure-template-repl-command "kaocha.repl/run (var <lt>ns<gt>/<lt>sel<gt>)"<ret>' \
    -docstring "run kaocha test for selected var"

    declare-user-mode ns-repl-commands
    map global ns-repl-commands n ': clojure-namespace-repl-command<ret>' \
    -docstring "Prompt for a REPL command to evaluate on the current namespace symbol"
    map global ns-repl-commands i ': clojure-namespace-repl-command in-ns<ret>' -docstring "in-ns"
    map global ns-repl-commands r ': clojure-namespace-repl-command remove-ns<ret>' -docstring "remove-ns"
    # map global ns-repl-commands t ': clojure-namespace-repl-command clojure.test/run-tests<ret>' \
    # -docstring "run-tests"
    map global ns-repl-commands t ': clojure-namespace-repl-command kaocha.repl/run<ret>' \
    -docstring "run all tests in namespace via kaocha"

    hook global WinSetOption filetype=clojure %{
      # Disabled because I find I usually just want a connected terminal.
      # set-option window repl_mode_new_repl_command 'bb nrepl-plus'
      # complete-command -menu repl-mode-set-new-repl-command shell-script-candidates %{
      #     printf '%s\n' 'bb nrepl-plus' 'lein repl :connect' 'lein repl'
      # }

      map window repl c ': enter-user-mode repl-commands<ret>' -docstring "REPL Commands"
      map window repl n ': enter-user-mode ns-repl-commands<ret>' -docstring "Namespace REPL Commands"

      hook -once -always window WinSetOption filetype=.* %{
        unset-option window repl_mode_new_repl_command
        unmap window repl c
        unmap window repl n
      }
    }
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-chtsh` plugin
# https://github.com/jordan-yee/kakoune-chtsh

plug "jordan-yee/kakoune-chtsh"

# ------------------------------------------------------------------------------
# Configuration for the `case.kak` plugin
# https://gitlab.com/FlyingWombat/case.kak

plug "https://gitlab.com/FlyingWombat/case.kak" config %{
    map global normal '`' ': enter-user-mode case<ret>'
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-surround` plugin
# https://github.com/h-youhei/kakoune-surround

# NOTE: Switching to kakoune-mirror instead
# plug "h-youhei/kakoune-surround" config %{
#     declare-user-mode surround

#     map global surround s ':surround<ret>' -docstring 'surround'
#     # TODO: Fix change-surround
#     map global surround c ':change-surround<ret>' -docstring 'change'
#     map global surround d ':delete-surround<ret>' -docstring 'delete'
#     map global surround t ':select-surrounding-tag<ret>' -docstring 'select tag'

#     map global user s ':enter-user-mode surround<ret>' -docstring 'surround mode'
# }

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-find` plugin
# https://github.com/occivink/kakoune-find

plug "occivink/kakoune-find"

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-phantom-selection` plugin
# https://github.com/occivink/kakoune-phantom-selection

plug 'occivink/kakoune-phantom-selection' config %{
    define-command phantom-selection-activate %{
        phantom-selection-add-selection
        map window normal ( ": phantom-selection-iterate-prev<ret>"
        map window normal ) ": phantom-selection-iterate-next<ret>"
    }

    define-command phantom-selection-stop %{
        phantom-selection-select-all
        phantom-selection-clear
        unmap window normal (
        unmap window normal )
    }

    map global user f ": phantom-selection-activate<ret>" \
    -docstring "Start phantom selection"
    map global user F ": phantom-selection-stop<ret>" \
    -docstring "Stop phantom selection"
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-vertical-selection` plugin
# https://github.com/occivink/kakoune-vertical-selection

# NOTE: This plugin is used by the kakoune-text-objects plugin.

plug 'occivink/kakoune-vertical-selection' config %{
    map global user v     ': vertical-selection-down<ret>' -docstring 'vertical selection down'
    map global user <a-v> ': vertical-selection-up<ret>' -docstring 'vertical selection up'
    map global user V     ': vertical-selection-up-and-down<ret>' -docstring 'vertical selection both'
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-sort-selections` plugin
# https://github.com/occivink/kakoune-sort-selections

plug 'occivink/kakoune-sort-selections' config %{
    # These mappings assume a selection user is defined above.
    map global selection s ': sort-selections<ret>' -docstring 'sort multiple selections'
    map global selection <a-s> ': sort-selections -reverse<ret>' -docstring 'sort multiple selections in reverse'
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-expand` plugin
# https://github.com/occivink/kakoune-expand

# NOTE: This is not working in a clj file, and I don't really use it, so
# disabling for now. I'll probably remove it at some point later.
# plug 'occivink/kakoune-expand' config %{
#     map -docstring "expand" global normal <c-x> ': expand<ret>'

#     # 'lock' mapping where pressing <space> repeatedly will expand the selection
#     declare-user-mode expand
#     map -docstring "expand" global expand <space> ': expand<ret>'
#     map -docstring "expand ↻" global user x       ': expand; enter-user-mode -lock expand<ret>'
# }

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-text-objects` plugin
# https://github.com/delapouite/kakoune-text-objects

# NOTE: Vertical selections require the kakoune-vertical-selection plugin.

plug 'delapouite/kakoune-text-objects'

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-auto-percent` plugin
# https://github.com/delapouite/kakoune-auto-percent

plug 'delapouite/kakoune-auto-percent' config %{
    unmap global normal (
    unmap global normal )
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-buffers` plugin
# https://github.com/delapouite/kakoune-buffers

plug "delapouite/kakoune-buffers" config %{
    # NOTE: These mappings assume <b> has been rebound or isn't needed.
    map global normal b ': enter-buffers-mode<ret>' -docstring 'buffers'
    map global normal B ': enter-user-mode -lock buffers<ret>' -docstring 'buffers (lock)'
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-mirror` plugin
# https://github.com/delapouite/kakoune-mirror

plug 'delapouite/kakoune-mirror' config %{
    map global normal "'" ': enter-user-mode -lock mirror<ret>'
}

# ------------------------------------------------------------------------------
# Configuration for the `kakoune-inc-dec` plugin
# https://gitlab.com/Screwtapello/kakoune-inc-dec/

try %{ source "%val{config}/plugins/kakoune-inc-dec/inc-dec.kak"
} catch %{ echo -debug "Failed to load `kakoune-inc-dec` plugin: not yet installed" }
plug "https://gitlab.com/Screwtapello/kakoune-inc-dec/" noload config %{
    map global normal <c-a> ': inc-dec-modify-numbers + 1<ret>'
    map global normal <c-a-a> ': inc-dec-modify-numbers - 1<ret>'
}

# ------------------------------------------------------------------------------
# Configuration for the `kak-rainbow` plugin
# https://github.com/Bodhizafa/kak-rainbow

plug 'Bodhizafa/kak-rainbow' config %{
    # [Partial Pallette](https://coolors.co/81f3e6-997ef1-ea4348-66d421-5c7aff)
    #                                rgb:FFFFFF+b cyan       green      blue       purple     red        orange     yellow
    set-option global rainbow_colors rgb:FFFFFF+b rgb:81F3E6 rgb:66D421 rgb:5C7AFF rgb:997EF1 rgb:EA4348 rgb:FF870F rgb:FCD569

    hook global WinSetOption filetype=(scheme|lisp|clojure) %{
        rainbow-enable-window
    }
}

# ------------------------------------------------------------------------------
# Configuration for the `eraserhd/kak-ansi` plugin
# https://github.com/eraserhd/kak-ansi

plug "eraserhd/kak-ansi"
