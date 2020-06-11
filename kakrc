# -----------------------------------------------------------------------------
# basic configuration

colorscheme gruvbox

# show line numbers
add-highlighter global/ number-lines -relative -hlcursor -min-digits 3

# show max-width helper line
set-option global autowrap_column 95
add-highlighter global/ column '%opt{autowrap_column}' default,white

# show matching brackets
add-highlighter global/ show-matching

# highlight special comment words
add-highlighter global/ regex \b(TODO|FIXME|XXX|NOTE)\b 0:default+rb

set-option global indentwidth 2
set-option global tabstop 2

# -----------------------------------------------------------------------------
# mappings

# use space for user mode leader key
# ----------------------------------

# rebind <space>
map global normal <space> , -docstring 'leader'
# rebind <backspace> to replace the old function of <space>
map global normal <backspace> <space> -docstring 'remove all sels except main'
map global normal <a-backspace> <a-space> -docstring 'remove main sel'

# perform a literal (non-regex) search in user mode
# -------------------------------------------------

map global user / ':exec /<ret>\Q\E<left><left>' -docstring 'literal search'

# paste from Windows file
# -----------------------

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

# -----------------------------------------------------------------------------
# PLUGINS

# load plugin manger
# NOTE: You must first clone the git repo for this to work:
#       `mkdir -p ~/.config/kak/plugins/`
#       `git clone https://github.com/andreyorst/plug.kak.git ~/.config/kak/plugins/plug.kak`
# ------------------
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload config %{ }

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
  # To discover other options or access command docs, view auto-complete
  # results of `:set-option global fzf` command.
} config %{
  map global normal <c-p> ': fzf-mode<ret>'
}

# surround
# --------

plug "h-youhei/kakoune-surround" config %{
  declare-user-mode surround
  map global surround s ':surround<ret>' -docstring 'surround'
  map global surround c ':change-surround<ret>' -docstring 'change'
  map global surround d ':delete-surround<ret>' -docstring 'delete'
  map global surround t ':select-surrounding-tag<ret>' -docstring 'select tag'
  map global user s ':enter-user-mode surround<ret>' -docstring 'surround mode'
}

# improved status bar
# -------------------

# NOTE: You may need to use a powerline font for things to look right.
plug "andreyorst/powerline.kak" defer powerline %{
  set-option global powerline_shorten_bufname short
  powerline-theme gruvbox
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
