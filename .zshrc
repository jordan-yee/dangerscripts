# The following lines were added by compinstall

zstyle ':completion:*' completer _complete _ignored _approximate
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

bindkey -v
# End of lines configured by zsh-newuser-install

# Dependencies referenced in this zshrc:
# - Rust
# - Kakoune
# - Git
# - WSL2
# - fd
# - fzf
# - Ranger
# - nix

# -----------------------------------------------------------------------------
# Misc

alias rz='source ~/.zshrc'

# Add directories to PATH
export PATH=$HOME/bin:$HOME/.local/bin:$PATH
export PATH=$HOME/.cargo/bin:$PATH # Rust

# Set default editor
export EDITOR='kak'
export VISUAL='kak' # NOTE: not sure what this is for, copied from a guide.

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='kak'
fi

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
function prompt-length() {
    emulate -L zsh
    local COLUMNS=${2:-$COLUMNS}
    local -i x y=$#1 m
    if (( y )); then
        while (( ${${(%):-$1%$y(l.1.0)}[-1]} )); do
             x=y
             (( y *= 2 ));
        done
        local xy
        while (( y > x + 1 )); do
            m=$(( x + (y - x) / 2 ))
            typeset ${${(%):-$1%$m(l.x.y)}[-1]}=$m
        done
    fi
    echo $x
}

function fill-line() {
    emulate -L zsh
    local left_len=$(prompt-length $1)
    local right_len=$(prompt-length $2 9999)
    local pad_len=$((COLUMNS - left_len - right_len - ${ZLE_RPROMPT_INDENT:-1}))
    if (( pad_len < 1 )); then
        # Not enough space for the right part. Drop it.
        echo -E - ${1}
    else
        local pad=${(pl.$pad_len.. .)}  # pad_len spaces
        echo -E - ${1}${pad}${2}
    fi
}

function set-prompt() {
    emulate -L zsh
    
    local top_left='%F{081}%~%f'
    local top_right='%F{220}$vcs_info_msg_0_%f %* %B%(?.%F{082}%?%f.%F{196}%?%f)%b'
    local bottom_left='%(!.->>.->) '
    local bottom_right=''
    
    PS1="$(fill-line "$top_left" "$top_right")"$'\n'$bottom_left
    RPS1=$bottom_right
}

setopt noprompt{bang,subst} prompt{cr,percent,sp}
autoload -Uz add-zsh-hook
add-zsh-hook precmd set-prompt

# -----------------------------------------------------------------------------
# Git

# prompt info
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
zstyle ':vcs_info:git:*' formats '[%b]'
zstyle ':vcs_info:*' enable git

# tab completion
autoload -Uz compinit && compinit

# -----------------------------------------------------------------------------
# WSL2

# Enable GUI applications to run on X server running on Windows
export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0

# -----------------------------------------------------------------------------
# Change cursor based on mode (vi)

# Reduce delay in switching to normal mode with vi key bindings
# 10ms for key sequences
KEYTIMEOUT=1

# Change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'

  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Use beam shape cursor on startup
echo -ne '\e[5 q'

# Use beam shape cursor for each new prompt
preexec() {
   echo -ne '\e[5 q'
}

# -----------------------------------------------------------------------------
# fzf (fuzzy finder) configuration

# This sets up fzf key bindings after installing with apt on Ubuntu 20.04,
# and therefore may not work for a different system's installation.
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# (See https://github.com/sharkdp/fd)
#   Ubuntu 20.04: sudo apt install fd-find
# The fd binary is named fdfind for Debian installs to prevent a naming
# conflict. Use this alias to if you don't have an existing fd command.
# NOTE: You may still have to use fdfind in scripts (e.g. fzf config below).
alias fd=fdfind

# Commands to use for key bindings
export FZF_ALT_C_COMMAND='fdfind --hidden --type d'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'

# Commands to use for fuzzy completion (**<tab>)
_fzf_compgen_path() {
  fd --hidden --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --exclude ".git" . "$1"
}

# Disable ALT-C binding to prevent esc-c from triggering fzf
# This is a problem when esc'ing out of insert mode in zsh with vi key bindings
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[[ $- =~ i ]] && bindkey -r '\ec'

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
# Stuff Automatically Added By Other Applications
# NOTE: This section should remain at the bottom.

if [ -e /home/jordan/.nix-profile/etc/profile.d/nix.sh ]; then . /home/jordan/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
