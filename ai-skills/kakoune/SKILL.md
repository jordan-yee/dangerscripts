---
name: kakoune
description: >-
  Author and debug Kakoune editor configuration and plugins written in kakscript
  — .kak files, kakrc, filetype/highlighter/indentation definitions, hooks,
  options, faces, key mappings, user modes, and shell-integration commands. Use
  this whenever editing a .kak file or kakrc, writing or modifying a Kakoune
  plugin, building a filetype or highlighter or indent-on-newline script,
  debugging kakscript quoting/expansion/hook problems, or answering "how do I … in
  Kakoune config". Covers command parsing and %-string quoting, the
  %val/%opt/%reg/%arg/%sh expansion system, evaluate-commands / execute-keys and
  draft contexts, the provide-module / require-module plugin pattern, highlighter
  regions, hook-group cleanup discipline, and POSIX-shell integration.
---

# Writing Kakoune scripts and plugins

Kakoune is configured and extended in **kakscript**: the same command language you
type at the `:` prompt, saved into `.kak` files. There is no embedded Lua/Vimscript
— the language is "commands + expansions," and anything beyond that is delegated to
a POSIX shell via `%sh{ … }`. This skill captures how that language actually parses
and runs, plus the conventions distilled from Kakoune's own `rc/` scripts so that
new code matches upstream quality.

This file is the map. Read the focused reference under `references/` for whatever
you are touching — do not guess at quoting or hook semantics, they are precise and
unforgiving.

## The five things that cause 90% of kakscript bugs

1. **`%{ … }` is verbatim now, re-parsed later.** A command/hook/map body stored in
   `%{ … }` is *not* expanded when defined. `%val{client}` inside it expands only
   when the body later runs as commands. This is why `%sh{}` blocks cannot use
   `%val{…}` and must read `$kak_*` environment variables instead. See
   `references/command-parsing-and-quoting.md` and `references/expansions.md`.
2. **Pick a delimiter that doesn't collide with the body.** `%{…}` is the default,
   but when the body contains unbalanced braces or regex, switch delimiters
   (`%[ ]`, `%( )`, `%< >`, or non-nestable `%| |`, `%§ §`, `%~ ~`, `%@ @`).
   Upstream nests a different delimiter at each level. See the quoting reference.
3. **Editing from a script must use a draft context.** `execute-keys -draft` (and
   usually `-itersel`) run keys against a *copy* of the user's selections so you
   don't clobber their cursor. Indentation/comment hooks are built entirely from
   this. See `references/execution-model.md`.
4. **Every hook you add in a filetype must be removable.** Tag hooks with
   `-group <ft>-…` and tear them down with a `hook -once -always window
   WinSetOption filetype=.* %{ remove-hooks window <ft>-.+ }`. Forgetting this
   leaks behavior across filetypes. See `references/hooks.md`.
5. **Prefix everything and document it.** Every non-hidden option/command/face is
   named after its script and carries a `-docstring`. See
   `references/plugin-structure-and-conventions.md`.

## Mental model

- **Commands** are whitespace-separated words terminated by newline or `;`. The
  first word is the command, the rest are arguments.
- **Expansions** (`%val{}`, `%opt{}`, `%reg{}`, `%arg{}`, `%sh{}`, `%file{}`,
  `%exp{}`) are substituted *before* the command runs — but only when unquoted or
  inside `"…"`, never inside `'…'` or `%{…}`.
- **Normal mode is the editing language.** There is no `delete-line` command — you
  script edits by feeding normal-mode keys to `execute-keys` (e.g. `x` to select a
  line, `d` to delete, `<a-k>regex<ret>` to keep selections matching a regex). The
  `<a-k>` "keep matching" key doubles as kakscript's `if`: it errors when nothing
  matches, and `try` swallows that error. Read `references/regex.md` for the regex
  dialect and `doc/autoedit.asciidoc` thinking in `references/execution-model.md`.
- **Client–server, shell-first.** Sorting, formatting, completion, linting are done
  by external Unix tools, not reimplemented. The integration surface is `%sh{}`,
  the `$kak_*` env vars, the command/response fifos, and `kak -p <session>` for
  async writes back into the editor. See `references/shell-and-portability.md`.

## Scopes (cross-cutting — used by options, hooks, highlighters, faces, maps, aliases)

Values resolve narrowest-first along this chain:

```
local  >  window  >  buffer  >  global
```

- `global` — the whole session. `buffer` — one buffer. `window` — one view onto a
  buffer (a buffer shown in two windows can differ, e.g. `filetype`). `local` — a
  temporary scope injected for the duration of each `evaluate-commands` and each
  `define-command` body.
- `set-option`/`unset-option` also accept `current` (the narrowest scope where the
  option is already set) and `buffer=<buffile>` to target a specific buffer.
- The `shared` scope is special to highlighters: filetype highlighters live in
  `shared/<lang>` and are attached to a window with `ref`.

## Which reference to open

| Working on… | Read |
|---|---|
| Quoting, `%`-strings, delimiters, escaping, typed expansions | `references/command-parsing-and-quoting.md` |
| `%val`/`%opt`/`%reg`/`%arg`/`%sh`/`%file`/`%exp`, `$kak_*` vars, fifos | `references/expansions.md` |
| `define-command`, `-params`, completion, aliases, `try`/`fail`/`nop`/`echo`/`info`/`prompt`/`on-key` | `references/commands.md` |
| `evaluate-commands` vs `execute-keys`, `-draft`/`-itersel`/`-save-regs`/`-no-hooks`, scripting edits | `references/execution-model.md` |
| `hook`, scopes, groups, `-once`/`-always`, the hook catalog, cleanup | `references/hooks.md` |
| `declare-option`/`set-option`, option types incl. `line-specs`/`range-specs`/`completions` | `references/options.md` |
| `add-highlighter`, regions, `ref`/`shared`, regex captures, specs highlighters, faces, markup | `references/highlighters-and-faces.md` |
| Key notation, `map`/`unmap`, modes, `declare-user-mode`/`enter-user-mode`, count/register forwarding | `references/keys-and-mappings.md` |
| Regex dialect, divergences from ECMAScript, `\K`/`\N`/`\Q\E`/`\h` | `references/regex.md` |
| POSIX shell rules, `printf` vs `echo`, `kakquote`, `join`, async detached jobs, `kak -p` | `references/shell-and-portability.md` |
| **A new filetype / syntax-highlighting / indent script** | `references/filetype-plugin-pattern.md` |
| **A command that drives an external tool** (build, grep, format, lint, completion, REPL) | `references/tool-plugin-pattern.md` |
| File layout, module loading, naming, docstrings, distribution, autoload | `references/plugin-structure-and-conventions.md` |

## Verifying kakscript (no test framework — verify by running)

Kakoune ships no unit-test harness for config; you confirm behavior by running it.

- **Read the live docs.** Inside Kakoune, `:doc <topic>` (e.g. `:doc expansions`,
  `:doc highlighters`) is the authoritative reference and matches the version
  installed. The same text lives in `doc/pages/*.asciidoc`.
- **Watch the debug buffer.** `:buffer *debug*` collects errors, hook failures, and
  anything written to stderr from a `%sh{}` block. `echo -debug %val{…}` and
  `set-option global debug 'hooks|shell|commands|keys'` make execution traceable.
- **Iterate without restarting.** `:source <file>` reloads a script. A `provide-module`
  body only evaluates once; to redefine it you need `provide-module -override`
  (and it must not have been required yet) or restart. During development, a clean
  session via `kak -n` (skip user config) plus an explicit `:source` is the fastest
  loop.
- **Inspect state.** `:debug options`, `:debug buffers`, `:debug faces`,
  `:debug mappings` dump current values.

## Upstream-quality checklist (this skill targets shareable code)

Before considering a script done, confirm against
`references/plugin-structure-and-conventions.md`:

- [ ] All options/commands/faces prefixed with the script name; underscores for
      option words, hyphens for command words.
- [ ] Every non-hidden command/option has a `-docstring`; internal helpers are `-hidden`.
- [ ] Shell in `%sh{}` is POSIX (`[ ]` not `[[ ]]`, `printf` not `echo`, no bashisms).
- [ ] Hooks are `-group`ed and torn down on filetype/win change.
- [ ] Highlighters live in `shared/` and are attached via `ref`, with matching removal.
- [ ] The plugin loads lazily (`provide-module` + a `KakBegin`/`WinSetOption`
      `require-module`) rather than running heavy work at source time.
- [ ] No reliance on a specific shell, GNU-only flags, or non-POSIX utilities unless
      that dependency is the whole point of the script and is documented.
