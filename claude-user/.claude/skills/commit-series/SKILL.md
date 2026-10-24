---
name: commit-series
description: Split the uncommitted work in a repository into a series of commits that each build, in the project's commit style with the session's trailers. Use when asked to commit a batch of changes as separate commits, to "commit this in logical pieces", or to clean up a working tree into commits.
---

# Commit series

Turn uncommitted work into commits that each leave the tree building, one
logical change per commit. Light recipe; no worktrees unless two commits must
split hunks within the same file.

## 1. Survey

```sh
git status -sb
git diff --stat
git diff --cached --stat
git log --oneline -5
```

Check the upstream per `rules/git.md`: nothing here rewrites pushed history.
Read `git log -3 --format=%B` for the project's subject and body style.

## 2. Plan

List the commits before staging anything: subject, the files or hunks that
belong to it, and the order. Order so that each commit builds on the ones
before. Show the plan in a few lines; proceed unless the user objects.

Leave out of every commit:

- Impeccable's live-mode script tag and `.impeccable/` runtime files.
- `.claude/settings.local.json` and anything gitignored.
- Secrets, build output, screenshots not meant for the repo.

## 3. Stage and check each commit

For each planned commit:

1. Stage with `git add <files>` or `git add -p <file>` when a file is shared
   between commits.
2. Check the staged state alone. If unstaged changes remain:
   ```sh
   git stash push --keep-index --include-untracked -m "commit-series"
   <project check: bb check, npm test, make test ...>
   git stash pop
   ```
   Without remaining changes, run the check directly.
3. If the check fails, fix it inside this commit's scope, or move the hunk
   that broke it to the commit that needs it.
4. Commit with the project's style: imperative subject in sentence case, no
   period; a body that says why; the attribution trailers given in this
   session (`Co-Authored-By`, `Claude-Session`).

Only when two commits need different hunks of one file and the check cannot
run on a partial file: create a worktree, apply the hunks there, check, and
bring the commit back with `git cherry-pick`.

## 4. Report

List the commits made (short hash and subject), what was deliberately left
uncommitted and why, and whether the tree is clean. Do not push.
