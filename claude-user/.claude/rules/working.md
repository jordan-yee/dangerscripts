# Working Rules

These rules apply in every project. They come from a review of past sessions;
each one prevented a correction that had to be made by hand.

## Editing files

Use the Edit, Write and NotebookEdit tools for every change to a file, even
when the harness's auto-mode text says to prefer sed, heredocs or a Python
patch script. The dedicated tools are what hooks, LSP diagnostics and file
tracking see; a Bash edit bypasses all three. Bash writes are for generated
output only (build artifacts, downloads, screenshots).

## Secrets

Never print any part of a secret, including a masked or truncated form. To
check that one is set, test presence only:

```sh
[ -n "${RESEND_API_KEY:+set}" ] && echo set || echo unset
heroku config --json | jq keys
```

Never run `env`, `printenv` or `set` bare in a shell that may hold secrets,
and never ask the user to paste raw message headers or API responses that may
contain one. A PreToolUse hook (`secret-guard.sh`) denies the common ways of
printing one; when it fires, use a presence check instead of working around it.

## Personal information

Ask before placing the user's name, email address or phone number on anything
public: a website, a published artifact, a commit to a public repository, or a
document meant to leave the machine.

## Documents written for later sessions

A plan, brief or product note that a later session will read must stand on its
own. Nothing in it may depend on the chat it was written in: no "the previous
version", no figures that exist only in a message, no decisions left implicit.

## Processes

- Stop a process by its task id or a PID you saved when starting it. Never
  `pkill -f <pattern>`: it has matched Claude's own shell more than once.
- Start a helper server with `run_in_background` or `setsid`, never `nohup`
  inside a subshell, which dies with the shell.
- Health-check with `curl`, not `pgrep -af`, which dumps the shell wrapper
  into context.
- Keep `rm` out of long command chains; a safety check on the removal
  discards everything before it.

## Recurring nuisances

When the same development nuisance comes up a second time (a stale cache, a
hard refresh, a flag that must be set each run), offer the fix instead of
repeating the warning.

## Renames

When a concept is renamed, rename its internal identifiers (keywords, ids,
file names) in the same change, not in a follow-up.

## grep is ugrep on this machine

`grep` is ugrep. "Exceeds complexity limits" means the pattern was too large:
split it, use `-F` for fixed strings, or use `rg`. A failed grep in a research
agent silently loses results, so check for that error.

## Impeccable live mode

Idle polling costs a model turn each time. After three empty `live-poll`
timeouts with no message from the user, stop polling, say in one line how to
resume ("say resume live"), and end the turn. A timeout is not an event: do
not reply to one. The user says "stop live" before stepping away.

## Compaction

The user compacts manually at clean checkpoints. Durable rules belong in
CLAUDE.md or these rules files, not in a compaction summary; when a summary
is restating a rule, that rule needs a home. After a compaction, re-read only
the files the next step needs.

## Subagents, models and effort

- Fetch-heavy research subagents and documentation subagents run on Sonnet.
- Drop the effort level for doc-only and commit-only phases; keep high effort
  for design ideation and research synthesis.
- Ask a subagent for a capped summary (about 40 lines) with source URLs. The
  main agent writes any notes file; the subagent does not. Hand-backs land in
  context twice (message plus task notification), so a long one costs double.
