# This script provides the `pytest` command for running pytest on the current file.

define-command pytest \
-docstring "Execute pytest on current file" \
%{
    evaluate-commands %sh{
        # Create a temporary fifo for communication
        output=$(mktemp -d -t kak-temp-XXXXXXXX)/fifo
        mkfifo ${output}
        # run command detached from the shell
        ( pytest $kak_buffile > ${output} 2>&1 & ) > /dev/null 2>&1 < /dev/null
        # Open the file in Kakoune and add a hook to remove the fifo
        echo "edit! -fifo ${output} *pytest-results*
    hook buffer BufClose .* %{ nop %sh{ rm -r $(dirname ${output})} }"
    }
}
