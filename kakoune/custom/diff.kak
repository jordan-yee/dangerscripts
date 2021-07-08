define-command -docstring 'Diff the current selections and display result in a new buffer.' \
diff-selections %{
    evaluate-commands %sh{
        eval set -- "$kak_quoted_selections"
        if [ $# -gt 1 ]; then
            echo "$1" > /tmp/a.txt
            echo "$2" > /tmp/b.txt
            diff -uw /tmp/a.txt /tmp/b.txt > /tmp/diff-result.diff
            echo 'edit -existing -readonly /tmp/diff-result.diff'
        else
            echo "echo -debug 'You must have at least 2 selections to compare.'"
        fi
    }
}
