# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' max-errors 2
zstyle :compinstall filename '/home/jyee/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt no_share_history
unsetopt share_history

setopt auto_cd

bindkey -v
# End of lines configured by zsh-newuser-install

# Dependencies referenced in this file:
# - Git
# - Kakoune
# - WSL2
# - fzf
#   - fd
# - Ranger
# - Rust
# - pyenv
#   - pyenv-virtualenv
# - direnv
# - Starship
# - nix
# - Flowstorm
# - Babashka

# -----------------------------------------------------------------------------
# Clojure Tools

function nrepl_port() {
    echo $(cat .nrepl-port)
}

function flowstorm() {
    # JDK 17 required for FlowStorm 3.9.0+ (without overriding dependencies)
    # sdk use java 17.0.10-zulu
    NREPL_PORT=$(cat .nrepl-port)
    echo "Starting Flowstorm; Connecting to port: $NREPL_PORT"
    # prev version: "4.0.2"
    clj -Sforce -Sdeps '{:deps {com.github.flow-storm/flow-storm-dbg {:mvn/version "4.4.6"}}}' \
    -X flow-storm.debugger.main/start-debugger :port $NREPL_PORT \
    :theme :dark :styles '"/home/jordan/.flow-storm/theme-overrides.css"'
}

# Autocomplete for babashka tasks (`bb` command)
# https://book.babashka.org/#_terminal_tab_completion
_bb_tasks() {
    local matches=(`bb tasks |tail -n +3 |cut -f1 -d ' '`)
    compadd -a matches
    _files # autocomplete filenames as well
}
compdef _bb_tasks bb

# -----------------------------------------------------------------------------
# Misc

alias rz='source ~/.zshrc'

alias ls='ls --human-readable --classify --color=auto'
alias lsa='ls --almost-all'

# Save time when needing to restart Windows Terminal to fix rendering bug
alias tma='tmux attach-session -t 0'

# Add directories to PATH
# This should probably be in .zshenv or .profile
export PATH=$HOME/bin:$HOME/.local/bin:/snap/bin:$PATH

# Reduce delay in switching to normal mode with vi key bindings
# 10ms for key sequences
KEYTIMEOUT=1

# Enable autocompletion of hidden files and directories
setopt globdots

# -----------------------------------------------------------------------------
# cdr

# Enable the cdr command
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# Enable completion for cdr
zstyle ':completion:*:*:cdr:*:*' menu selection

# -----------------------------------------------------------------------------
# Prompt

# Set built-in prompt
# See `PROMPT THEMES` section in `man zshcontrib` for more info
#autoload -U promptinit
#promptinit
# My choice built-in theme:
#prompt walters blue

# Set custom prompt
# Placeholders:
# http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Prompt-Expansion
# 2-line prompt:
# https://gist.github.com/romkatv/2a107ef9314f0d5f76563725b42f7cab
# function prompt-length() {
#     emulate -L zsh
#     local COLUMNS=${2:-$COLUMNS}
#     local -i x y=$#1 m
#     if (( y )); then
#         while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
#              x=y
#              (( y *= 2 ));
#         done
#         local xy
#         while (( y > x + 1 )); do
#             m=$(( x + (y - x) / 2 ))
#             typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
#         done
#     fi
#     echo $x
# }

# function fill-line() {
#     emulate -L zsh
#     local left_len=$(prompt-length $1)
#     local right_len=$(prompt-length $2 9999)
#     local pad_len=$((COLUMNS - left_len - right_len - ${ZLE_RPROMPT_INDENT:-1}))
#     if (( pad_len < 1 )); then
#         # Not enough space for the right part. Drop it.
#         echo -E - ${1}
#     else
#         local pad=${(pl.$pad_len.. .)}  # pad_len spaces
#         echo -E - ${1}${pad}${2}
#     fi
# }

# function set-prompt() {
#     emulate -L zsh

#     local top_left='%F{081}%~%f'
#     local top_right='%F{220}$vcs_info_msg_0_%f %* %B%(?.%F{082}%?%f.%F{196}%?%f)%b'
#     local bottom_left='%(!.->>.->) '
#     local bottom_right=''

#     PS1="$(fill-line "$top_left" "$top_right")"$'\n'$bottom_left
#     RPS1=$bottom_right
# }

# setopt noprompt{bang,subst} prompt{cr,percent,sp}
# autoload -Uz add-zsh-hook
# add-zsh-hook precmd set-prompt

# -------------------------------------
# Display vcs info in prompt

# autoload -Uz vcs_info
# precmd_vcs_info() { vcs_info }
# precmd_functions+=( precmd_vcs_info )
# setopt prompt_subst
# zstyle ':vcs_info:git:*' formats '[%b]'
# zstyle ':vcs_info:*' enable git

# -------------------------------------
# Change cursor based on mode (vi)

# Change cursor shape for different vi modes
# function zle-keymap-select {
#   if [[ ${KEYMAP} == vicmd ]] ||
#      [[ $1 = 'block' ]]; then
#     echo -ne '\e[1 q'

#   elif [[ ${KEYMAP} == main ]] ||
#        [[ ${KEYMAP} == viins ]] ||
#        [[ ${KEYMAP} = '' ]] ||
#        [[ $1 = 'beam' ]]; then
#     echo -ne '\e[5 q'
#   fi
# }
# zle -N zle-keymap-select

# # Use beam shape cursor on startup
# echo -ne '\e[5 q'

# # Use beam shape cursor for each new prompt
# preexec() {
#    echo -ne '\e[5 q'
# }

# -----------------------------------------------------------------------------
# Git

alias lg='lazygit'

alias gsa='git status'
alias ga='git add'
alias gc='git commit'
alias gf='git fetch'
alias gfs='git fetch && git status'
alias gcm='git commit --message'
alias gpl='git pull'
alias gps='git push'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gx='git checkout'
alias gxb='git checkout -b'

function print-git-aliases() {
    echo "gsa = 'git status'"
    echo "ga  = 'git add'"
    echo "gc  = 'git commit'"
    echo "gf  = 'git fetch'"
    echo "gfs = 'git fetch && git status'"
    echo "gcm = 'git commit --message'"
    echo "gpl = 'git pull'"
    echo "gps = 'git push'"
    echo "gb  = 'git branch'"
    echo "gba = 'git branch --all'"
    echo "gbd = 'git branch --delete'"
    echo "gx  = 'git checkout'"
    echo "gxb = 'git checkout -b'"
}

alias gh=print-git-aliases

# -----------------------------------------------------------------------------
# Kakoune

if [[ -n $SSH_CONNECTION ]]; then
    # Set default editor for remote sessions
    export EDITOR='vi'
    export VISUAL='vi'
else
    # Set default editor for local sessions
    export EDITOR='kak'
    export VISUAL='kak'
fi

# 1 Kakoune session per project
# Inspired by:
# https://github.com/mawww/kakoune/wiki/Kak-daemon-helper-:-1-session-per-project
# Modified and expanded to scope session to git repo project.
kaks() {
    git_dir=$(git rev-parse --show-toplevel 2>/dev/null)

    if [ $? -eq 0 ]; then
        server_name=$(basename $git_dir)
    else
        # If not in a git repo create create a session to the current directory.
        server_name=$(basename `pwd`)
    fi

    socket_file=$(kak -l | grep $server_name)

    if [ "$socket_file" = "" ]; then
        # Create new kakoune daemon for either the current dir or git repo
        echo "Starting kakoune daemon for session name, $server_name"
        setsid kak -d -s $server_name
    fi

    # and run kakoune (with any arguments passed to the script)
    echo "Start kakoune client and connect to session, $server_name, with args $@"
    kak -c $server_name $@
}

# -----------------------------------------------------------------------------
# WSL2

# Enable GUI applications to run on X server running on Windows
#export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0

# Open Windows browser from WSL
export DISPLAY=:0
export BROWSER=/usr/bin/wslview

alias open=explorer.exe

# wsl-notify-send
# https://github.com/stuartleeks/wsl-notify-send
notify-send() { wsl-notify-send.exe --category $WSL_DISTRO_NAME "${@}"; }

# -----------------------------------------------------------------------------
# fzf (fuzzy finder) configuration

# This sets up fzf key bindings and completion for zshell:
source /home/jordan/github/junegunn/fzf/shell/completion.zsh
source /home/jordan/github/junegunn/fzf/shell/key-bindings.zsh

# Commands to use for key bindings
export FZF_COMPLETION_TRIGGER='~~'
export FZF_ALT_C_COMMAND='fd --hidden --type d'
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Commands to use for fuzzy completion (**<tab>)
_fzf_compgen_path() {
  fd --hidden --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --exclude ".git" . "$1"
}

# -----------------------------------------------------------------------------
# Ranger

# Automatically cd to directory after exiting ranger
rangercd() {
    temp_file="$(mktemp -t "ranger_cd.XXXXXXXXXX")"
    ranger --choosedir="$temp_file" -- "${@:-$PWD}"
    if chosen_dir="$(cat -- "$temp_file")" && [ -n "$chosen_dir" ] && [ "$chosen_dir" != "$PWD" ]; then
        cd -- "$chosen_dir"
    fi
    rm -f -- "$temp_file"
}

# -----------------------------------------------------------------------------
# Rust

export PATH=$HOME/.cargo/bin:$PATH # Rust

# -----------------------------------------------------------------------------
# pyenv
# NOTE: This section should be placed toward the end of the shell config file.

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

# NOTE: This requires the pyenv-virtualenv plugin to be installed.
# Auto activate/deactivate virtualenvs when navigating dirs pyenv-virtualenv
eval "$(pyenv virtualenv-init -)"

# -----------------------------------------------------------------------------
# direnv
# NOTE: This section should be placed toward the end of the shell config file.

# NOTE: This must come after the nix script is executed if you installed direnv
# via nix.
# eval "$(direnv hook zsh)"

# -----------------------------------------------------------------------------
# Starship prompt

# NOTE: You'll have to choose between this or the from-scratch prompt defined
#       above.
# eval "$(starship init zsh)"

# -----------------------------------------------------------------------------
# Stuff Automatically Added By Other Applications
# NOTE: This section should remain at the bottom.

# Nix
if [ -e /home/jordan/.nix-profile/etc/profile.d/nix.sh ]; then . /home/jordan/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
