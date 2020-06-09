# -----------------------------------------------------------------------------
# basic configuration

colorscheme palenight

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

map global user / ':exec /<ret>\Q\E<left><left>'

# paste from Windows file
# -----------------------

map global user P '!cat /mnt/c/Users/jyee_/clipboard.txt<ret>'
map global user p '<a-!>cat /mnt/c/Users/jyee_/clipboard.txt<ret>'

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
# ------------------
source "%val{config}/plugins/plug.kak/rc/plug.kak"

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

plug "andreyorst/fzf.kak" config %{
  map global normal <c-p> ': fzf-mode<ret>'
}
