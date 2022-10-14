# A command for cloning the current file.

# TODO: Copy contents of current buffer into new buffer at path, unsaved
#   OR  Copy current file and edit the copied file?

# TODO: get current file path (%val{buffile})
# TODO: get current filename
# TODO: get current directory

# TODO: Optional new filename as arg, with default based on current file name if no arg given.
# define-command -override clone-file \
# -docstring 'Edit a copy of the current file.' \
# %{
#     execute-keys '%\"fy'
#     edit "copy"
#     execute-keys '\"fR'
# }


# TODO: Optional new filename as arg, with default based on current file name if no arg given.
define-command clone-buffer \
-docstring 'Edit a copy of the current file in a new buffer (unsaved).' \
%{
    execute-keys '%\"fy'
    edit "copy"
    execute-keys '\"fR'
}
