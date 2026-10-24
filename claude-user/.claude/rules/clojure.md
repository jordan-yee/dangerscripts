# Clojure Language Rules

These rules apply to Clojure code anywhere it appears: `.clj`, `.cljs`, `.cljc`,
`.cljx`, and `.bb` files, one-off expressions run from the shell, and code
blocks inside other files such as markdown or HTML.

## Evaluating Clojure code at the REPL

When you need to evaluate Clojure code you can use the `clj-nrepl-eval` command
to evaluate code against an nREPL server. **ALWAYS** prefer this approach over other
methods, unless there is definite requirement for why another approach should
be used (e.g. for a one-off test of a Clojure invocation requiring a custom
dependency or alias specified via of Clojure CLI tools).

Use the `/clojure-nrepl` command for info on how evaluate Clojure code via the
repl using the `clj-nrepl-eval` CLI command.

Usually, the user will manually start an nREPL server manually, but if requested
you can start a new REPL instance using the `/start-nrepl` command.

## Toolchain choices

Prefer upgrading a project over pinning the toolchain it was last built with.
Before installing an old Java, Leiningen or Clojure version to make something
run, present the options (upgrade, or pin and why) and wait for the choice.

Defaults for a new or revived project, unless the project says otherwise:

- `deps.edn` and the Clojure CLI, not Leiningen.
- shadow-cljs for ClojureScript, with npm for JavaScript dependencies.
- The latest LTS Java and the latest stable Clojure. Check the current
  versions rather than quoting remembered ones.
- Babashka tasks (`bb.edn`) as the one place the project's commands live.
