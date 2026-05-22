# POSIX shell and portability

`%sh{}` blocks must run under a bare POSIX `/bin/sh`, not bash. For shareable code
this is non-negotiable — users have dash, busybox, etc. Source:
`doc/writing_scripts.asciidoc`, `doc/coding-style.asciidoc`.

## POSIX rules (the ones that actually bite)

- **`printf`, not `echo`.** `echo` is implementation-defined for backslashes/flags.
  Use `printf %s\\n "$var"` or `printf 'value: %s\n' "$var"`. (Plain `echo "set …"`
  is fine only when the text has no ambiguous characters.)
- **`[ ]`, not `[[ ]]`.** `[[` is a bashism.
- **No `&>`.** Redirect both streams as `>/dev/null 2>&1`.
- **Parameter expansion over external tools:** `"${var##*/}"` for basename,
  `"${var%/*}"` for dirname, `"${var%.*}"` to strip an extension — avoids spawning
  `basename`/`dirname`.
- **No `=~`.** For regex tests use `expr`:
  `expr "$var" : '[a-z]*' >/dev/null` (success if matches; the pattern is implicitly
  anchored at the start — don't add `^`/`$`).
- Avoid GNU-only flags. If a `sed`/`awk`/`grep` feature is GNU-specific, find the
  POSIX form or document the dependency.
- `local` is not POSIX. Upstream occasionally uses it but strictly-portable code
  should avoid it (use subshells or distinct names).

## Quoting data across the kakscript ↔ shell boundary

Two boundaries to respect: (1) values you *read* from Kakoune into the shell, and
(2) kakscript you *print* from the shell for Kakoune to run.

### Reading list values

Use the `$kak_quoted_*` form and `eval set --` (never iterate raw lists):

```
eval set -- "$kak_quoted_opt_alt_dirs"
for dir; do … "$dir" … ; done
```

### Emitting safe kakscript: the `kakquote` helper

When printing a value back as a kakscript string argument, wrap it as a single-quoted
kak string with embedded quotes doubled. The upstream helper (from `modeline.kak`,
`lint.kak`):

```
kakquote() { printf "%s" "$*" | sed "s/'/''/g; 1s/^/'/; \$s/\$/'/"; }
# usage:
printf 'set-option buffer %s %s\n' "$key" "$(kakquote "$value")"
```

This produces `'…'` with internal `'` → `''`, which is exactly Kakoune's
single-quote escaping. Reach for it whenever a value could contain spaces, quotes, or
kakscript metacharacters.

### Building alternations / joining lists: the `join` helper

Every filetype with keyword lists uses this to make `a|b|c` (for regex) or
`a b c` (for `static_words`):

```
join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }
add-highlighter … regex \b($(join "${keywords}" '|'))\b 0:keyword
declare-option str-list lang_static_words $(join "${keywords} ${types}" ' ')
```

## Async / background work (don't freeze the editor)

A `%sh{}` blocks Kakoune until the script finishes **and** its stdout/stderr close.
For anything slow, detach a subshell with all three std streams redirected, and write
results back through the session socket with `kak -p`:

```
nop %sh{ (
    trap - INT QUIT                       # restore default signals in the child
    result=$(slow_command)
    printf %s\\n "evaluate-commands -client $kak_client echo -markup '{Information}done'" \
        | kak -p "$kak_session"
) > /dev/null 2>&1 < /dev/null & }
```

Key points:

- `( … ) >/dev/null 2>&1 </dev/null &` — detached so the parent `%sh{}` returns
  immediately. Without the redirections Kakoune waits on the open fds.
- `kak -p "$kak_session"` pipes kakscript into the running session. There's no client
  context, so wrap UI-affecting commands in `evaluate-commands -client "$kak_client"`.
- The fifo helpers (`fifo.kak`, `make.kak`, `grep.kak`) wrap this for streaming a
  command's output into a buffer; prefer them over hand-rolling. See
  `tool-plugin-pattern.md`.
- For one-shot async completion results, write a `completions` option via `kak -p`
  (see `interfacing.asciidoc` / `ctags.kak`).

## Temp files and cleanup

- `mktemp` with a portable template and `${TMPDIR:-/tmp}`:
  `dir=$(mktemp -d "${TMPDIR:-/tmp}"/kak-thing.XXXXXXXX)`.
- Remove temp files when the associated buffer/fifo closes, via an `-always -once`
  hook so cleanup runs even with hooks disabled:
  `hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname "$out") } }`.
- For lock-style coordination, `mkdir` is the portable atomic primitive (ctags uses
  `mkdir .tags.kaklock` + `trap 'rmdir …' EXIT`).

## Debugging shell blocks

- Anything on **stderr** goes to `*debug*`. Add `printf '%s\n' "debug: $x" >&2` while
  developing.
- `set-option global debug 'shell'` logs each shell invocation.
- Remember `evaluate-commands %sh{}` parses **stdout** as kakscript — a stray
  `echo`/diagnostic on stdout becomes a (broken) command. Send diagnostics to stderr.
