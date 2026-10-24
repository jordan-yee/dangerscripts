---
name: wrap-up
description: Session-close checklist. Reports unpushed and uncommitted work, processes Claude started that are still running, published artifacts, claims made without verification, and learnings worth recording in CLAUDE.md or the rules. Use when the user asks "anything else to wrap up?", is ending a session, or before a long pause.
---

# Wrap up

Produce one short report, under 20 lines, then stop. Fix nothing unless
asked; the point is to leave nothing hidden.

## Check

1. **Commits.** `git status -sb` and `git log --oneline @{u}..`. Report
   uncommitted changes and unpushed commits, per repository touched.
2. **Processes.** Background tasks and servers this session started (dev
   servers, REPLs, watchers, pollers, Impeccable live mode). Say which are
   still running and how to stop each. Stop only the ones Claude started and
   the user did not ask to keep.
3. **Artifacts.** Pages published with the Artifact tool, files written
   outside the repository, downloads. Give the URLs and paths.
4. **Unverified work.** Anything reported as done that was not run, tested
   or looked at (an untested code path, a page not re-rendered after an edit,
   a figure not re-read from source).
5. **Open questions.** Decisions deferred to the user during the session.
6. **Learnings.** Rules or facts that had to be stated in chat this session
   and have no durable home yet. Propose each as a one-line addition to
   CLAUDE.md, PRODUCT.md, docs, or `~/.claude/rules/`, and offer to write
   them.

## Report

```
Wrap-up
- Commits: <n> uncommitted files, <n> unpushed commits on <branch>
- Running: <process> (<how to stop>), ...
- Artifacts: <url or path>, ...
- Unverified: ...
- Open: ...
- Learnings to record: ...
```

Omit any line that is empty. End with the one next step, if there is one.
