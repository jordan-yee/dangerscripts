#!/usr/bin/env bash
# PreToolUse hook for Bash: denies commands that would print a secret.
#
# Reads the hook JSON on stdin, looks at tool_input.command, and answers with
# a deny decision when the command would echo a secret-looking variable, dump
# the environment, print config values from Heroku or Infisical, or read a
# known credential file. Presence checks (${VAR:+set}, ${#VAR}) and name-only
# listings (heroku config --json | jq keys) pass. See rules/working.md,
# "Secrets". It is a regex guard: it closes the common ways, not every way
# (a value copied into another variable, a heredoc body, `node -e`, or the
# Read tool are outside it). On malformed input it allows, so a broken hook
# never blocks work.
set -u
cmd=$(jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

deny() {
  jq -cn --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}
has() { printf '%s' "$1" | grep -qE -- "$2"; }

secretish='[A-Z0-9_]*(KEY|SECRET|TOKEN|PASSWORD|PASSWD|PASS|PRIVATE|CREDENTIAL|DSN|DATABASE_URL|REDIS_URL)[A-Z0-9_]*'
# Where a command may begin: a line start, a separator, a subshell, a
# backtick, a quote (sh -c '...') or whitespace.
start='(^|[;&|(`"'"'"']|\s)'
# The same without whitespace or quotes, for words that are also common
# arguments (set, export).
cmdstart='(^|[;&|(`]\s*)'
wstart='(^|[;&|(`]|\s)'

# The echo test runs on the command with the safe expansions removed, so a
# presence check on one line does not excuse a value on the next.
stripped=$(printf '%s' "$cmd" | sed -E 's/\$\{[A-Z0-9_]+:\+[^}]*\}//g; s/\$\{#[A-Z0-9_]+\}//g')
if has "$stripped" "${start}(echo|printf)\\b[^;&|]*\\\$\\{?${secretish}(\\}|\\b|:)"; then
  deny "This would print a secret-looking variable. Check presence with \${VAR:+set} instead (rules/working.md, Secrets)."
fi
if has "$cmd" "<<<\\s*[\"']?\\\$\\{?${secretish}"; then
  deny "This feeds a secret-looking variable to a command. Check presence with \${VAR:+set} instead."
fi

# The whole environment, or a variable by name.
if has "$cmd" '(^|[;&|(`"'"'"']|\s|--\s)(/usr/bin/)?(printenv|env)(\s|$|[;&|>)])' && ! has "$cmd" "${start}env\\s+[A-Z0-9_]+="; then
  deny "Dumping the environment, or printing a variable by name, can print secrets. Check one variable's presence with \${VAR:+set}."
fi
if has "$cmd" "${cmdstart}(declare|typeset)\\s+-[a-z]*p\\b" || has "$cmd" "${cmdstart}(set|export)(\\s+-p)?\\s*($|[;&|>)])"; then
  deny "That prints shell variables with their values. Check one variable's presence with \${VAR:+set}."
fi

# Heroku and Infisical values. Only the name-only forms pass, and only when
# the jq follows the command in the same pipeline.
if has "$cmd" '\bheroku\s+config:get\b' || has "$cmd" '\bheroku\s+pg:credentials'; then
  deny "That prints a secret value. For names only: heroku config --json | jq keys"
fi
if has "$cmd" '\bheroku\s+config(\s|$)' && ! has "$cmd" '\bheroku\s+config\s+--json\s*\|\s*jq\s+(-[a-z]+\s+)*["'"'"']?keys["'"'"']?\s*($|[;&|)])'; then
  deny "heroku config prints secret values. Use: heroku config --json | jq keys"
fi
if has "$cmd" '\binfisical\s+(secrets|export)\b' && ! has "$cmd" '\binfisical\s+secrets\b[^;&|]*\|\s*jq\s+[^;&|]*secretKey' || has "$cmd" 'secretValue'; then
  if ! has "$cmd" '\binfisical\s+(secrets|export)\s+--help\s*$'; then
    deny "infisical secrets prints secret values. List names only: infisical secrets --output json | jq 'map(.secretKey)'"
  fi
fi

# Known credential files, matched as paths. Examples and public keys pass.
# Readers take the file anywhere; searchers, whose first argument is a
# pattern, only when the file is a later argument.
file='((^|[[:space:]/'"'"'"=])\.env(rc|\.[A-Za-z0-9_-]+)?|\.netrc|\.credentials\.json|\.git-credentials|\.aws/credentials|id_(rsa|ed25519|ecdsa))([[:space:]'"'"'"]|$)'
if { has "$cmd" "${wstart}(cat|head|tail|less|more|bat|strings|nl|cp|od|xxd)\\b[^;&|]*${file}" \
     || has "$cmd" "${wstart}(grep|rg|sed|awk|cut)\\b(\\s+-\\S+)*\\s+[^-[:space:]]\\S*[^;&|]*${file}"; } \
   && ! has "$cmd" '\.env\.(example|sample|template|dist)\b'; then
  deny "That reads a credential file. Say which setting you need and check its presence instead."
fi

exit 0
