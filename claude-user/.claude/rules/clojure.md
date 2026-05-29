---
paths:
  - "**/*.clj"
  - "**/*.cljs"
  - "**/*.cljc"
  - "**/*.cljx"
  - "**/*.bb"
---

# Clojure Language Rules

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
