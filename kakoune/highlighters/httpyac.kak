# Highlighters for httpYac scripts: https://httpyac.github.io/

# Starting with skeleton from:
# https://zork.net/~st/jottings/Intro_to_Kakoune_highlighters.html
#
# Setting up all the highlighters for this syntax
# could be expensive, so we'll define them inside a module
# that won't be loaded until we need it.
#
# Because this module might contain a bunch of regexes with
# unbalanced grouping symbols, we'll use some other character
# as a delimiter.
# START MODULE
provide-module -override httpyac %&
    # Define our highlighters in the shared namespace,
    # so we can link them later.
    add-highlighter -override shared/httpyac regions

    # A region from a `#` to the end of the line is a comment.
    # TODO: Lines starting with `#` are comment type 1 or metadata lines
    add-highlighter -override shared/httpyac/comment1 region '#' '\n' group
    add-highlighter -override shared/httpyac/comment1/ fill comment
    add-highlighter -override shared/httpyac/comment1/ \
        regex @\w+ 0:variable

    add-highlighter -override shared/httpyac/comment2 region '//' '\n' fill comment
    add-highlighter -override shared/httpyac/comment3 region '/\*' '\*/' fill comment

    # A region starting and ending with a double-quote
    # is a group of highlighters.
    add-highlighter -override shared/httpyac/dqstring region '"' '"' group

    # By default, a double-quoted string is string-coloured.
    add-highlighter -override shared/httpyac/dqstring/ fill string

    # Some backslash-escaped characters are effectively keywords,
    # but most are errors.
    add-highlighter -override shared/httpyac/dqstring/ \
        regex (\\[\\abefhnrtv\n])|(\\.) 1:keyword 2:Error

    add-highlighter -override shared/httpyac/sqstring region "'" "'" group
    add-highlighter -override shared/httpyac/sqstring/ fill string

    # JavaScript Blocks.
    try %{ require-module javascript }
    add-highlighter shared/httpyac/script region "\{\{" "\}\}" ref javascript

    # Request Line.
    add-highlighter -override shared/httpyac/url region \
        "GET|POST|PUT|PATCH|DELETE|GRPC|SSE|WS|MQTT|AMQP " "\n" group
    add-highlighter -override shared/httpyac/url/ fill link
    add-highlighter -override shared/httpyac/url/ \
        regex GET|POST|PUT|PATCH|DELETE|GRPC|SSE|WS|MQTT|AMQP 0:keyword

    # Everything outside a region is a group of highlighters.
    add-highlighter -override shared/httpyac/other default-region group

    # Highlighting for numbers.
    add-highlighter -override shared/httpyac/other/ \
        regex \b(\+|-)?[0-9]+(\.[0-9]+)? 0:value

    # Highlighting for booleans.
    add-highlighter -override shared/httpyac/other/ \
        regex true|false 0:value

    # Highlighting for keywords.
    add-highlighter -override shared/httpyac/other/ \
        regex Content-Type|Content-Disposition|Authorization|Cookie|Event 0:keyword

    # Highlighting for operators.
    add-highlighter -override shared/httpyac/other/ \
        regex =|==|!=|>|>=|<|<=|\?\? 0:operator

    # Highlighting for variables definitions.
    add-highlighter -override shared/httpyac/other/ \
        regex @\w+ 0:variable

# END MODULE
&

remove-hooks global httpyac
# When a window's `filetype` option is set to this filetype...
hook -group httpyac global WinSetOption filetype=httpyac %{
    # Ensure our module is loaded, so our highlighters are available
    require-module httpyac

    # Link our higlighters from the shared namespace
    # into the window scope.
    add-highlighter -override window/httpyac ref httpyac

    # Add a hook that will unlink our highlighters
    # if the `filetype` option changes again.
    hook -once -always window WinSetOption filetype=.* %{
        remove-highlighter window/httpyac
    }
}

# Lastly, when a buffer is created for a new or existing file,
# and the filename ends with `.example`...
hook -group httpyac global BufCreate .+\.(http|rest) %{
    # ...we recognise that as our filetype,
    # so set the `filetype` option!
    set-option buffer filetype httpyac
}
