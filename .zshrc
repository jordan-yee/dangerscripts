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
bindkey -v
# End of lines configured by zsh-newuser-install

# -----------------------------------------------------------------------------
# Misc

# Set custom prompt
PS1='%3~ %# '

# Set default editor
export EDITOR='kak'
export VISUAL='kak'

# -----------------------------------------------------------------------------
# Change cursor based on mode (vi)

# Remove mode switching delay
KEYTIMEOUT=5

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
# fzf (fuzzy finder)
# NOTE: In Progress

# This sets up fzf key bindings after installing with apt on Ubuntu 20.04,
# and therefore may not work for a different system's installation.
source /usr/share/doc/fzf/examples/key-bindings.zsh
source /usr/share/doc/fzf/examples/completion.zsh

# Use fd instead of the default find command for listing path candidates.
# (See https://github.com/sharkdp/fd)
#   Ubuntu 20.04: sudo apt install fd-find
#   Alias following installation instructions for apt package:
alias fd=fdfind

# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# Use fd as default command when input is tty
export FZF_DEFAULT_COMMAND='fd --type f'
