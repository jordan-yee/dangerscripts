# Git Rules

These rules apply to git in every project.

## Rewriting history

Before a rebase, amend or reset that would rewrite commits, check whether the
branch has been pushed:

```sh
git status -sb            # shows the upstream and ahead/behind
git log --oneline @{u}..  # commits not yet on the upstream
```

If any commit being rewritten is already on the upstream, stop and ask. Never
force-push without being asked to in that turn. A branch the user pushed
between turns counts as pushed.

## Commits

Commit only when asked, and then one logical change per commit, each leaving
the tree building. Subject in the imperative, sentence case, no trailing
period; a body that says why, not what; the attribution trailers the session
provides. The `/commit-series` skill splits a batch of uncommitted work into
such commits.
