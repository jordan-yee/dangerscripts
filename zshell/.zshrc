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

# -----------------------------------------------------------------------------
# cdr

# Enable the cdr command
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# Enable completion for cdr
zstyle ':completion:*:*:cdr:*:*' menu selection

# lint only the clojure files that have been changed in the current branch
function lint-local-branch-changes() {
    clj-kondo --lint $(git diff --name-only origin/master...HEAD | grep -E '\.clj[sc]?$')
}

# -----------------------------------------------------------------------------
# Misc / System

alias rz='source ~/.zshrc'

alias ls='ls --human-readable --classify --color=auto'
alias lsa='ls --almost-all'

# Save time when needing to restart Windows Terminal to fix rendering bug
alias tma='tmux attach-session -t 0'

# Add directories to PATH
# This should probably be in .zshenv or .profile
# export PATH=$HOME/bin:$HOME/.local/bin:/snap/bin:$PATH
export PATH=$HOME/bin:$HOME/.local/bin:$PATH

# Reduce delay in switching to normal mode with vi key bindings
# 10ms for key sequences
KEYTIMEOUT=1

# Enable autocompletion of hidden files and directories
setopt globdots

# --------------------------------------
# Sway / GUI stuff

export XDG_SESSION_TYPE=wayland

# Allows xdg-open to open programs within the VM, instead of windows
export DE=generic
export BROWSER=google-chrome

# From the Sway wiki, a fix for potential issues with Java applications:
# this doesn't seem to get set so I'm setting it here in case it helps
export XDG_SESSION_DESKTOP=sway
if [ "$XDG_SESSION_DESKTOP" = "sway" ] ; then
    # https://github.com/swaywm/sway/issues/595
    export _JAVA_AWT_WM_NONREPARENTING=1
fi

# this is suggested as a potential cursor fix, but just causes both the linux
#   and windows cursors to be drawn over the sway window...
# export WLR_NO_HARDWARE_CURSORS=1

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
# Editor

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
# fzf (fuzzy finder) configuration

# --------------------------------------
# For Brew Installation

# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# --------------------------------------
# For Other Installation

# # This sets up fzf key bindings and completion for zshell:
# source /home/jordan/github/junegunn/fzf/shell/completion.zsh
# source /home/jordan/github/junegunn/fzf/shell/key-bindings.zsh

# # Commands to use for key bindings
# export FZF_COMPLETION_TRIGGER='~~'
# export FZF_ALT_C_COMMAND='fd --hidden --type d'
# export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
# export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# # Commands to use for fuzzy completion (**<tab>)
# _fzf_compgen_path() {
#   fd --hidden --exclude ".git" . "$1"
# }

# _fzf_compgen_dir() {
#   fd --type d --hidden --exclude ".git" . "$1"
# }

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

# rustup installer may have already configured everything.
# there was a question about whether I need to source a certain env file here.

# Maybe not needed, per above comment
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
eval "$(direnv hook zsh)"

# -----------------------------------------------------------------------------
# Starship prompt

eval "$(starship init zsh)"

# -----------------------------------------------------------------------------
# Stuff Automatically Added By Other Applications
# NOTE: This section should remain at the bottom.
# Possibly expected entries:
# - sdkman
# - nvm
# - nix
