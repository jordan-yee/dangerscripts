#!/usr/bin/env bash

input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // .model.id // "Unknown"')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Leading Claude Code version, set off from the rest by a vertical divider.
version=$(echo "$input" | jq -r '.version // empty')
if [ -n "$version" ]; then
  version_prefix="v${version} │ "
else
  version_prefix=""
fi

# Effort level, from the live session value on stdin (.effortLevel is the legacy key).
model_id=$(echo "$input" | jq -r '.model.id // ""')
effort=$(echo "$input" | jq -r '.effort.level // .effortLevel // empty')

if [ -n "$effort" ] && ! echo "$model_id" | grep -qi "haiku"; then
  effort_label=" [$effort]"
else
  effort_label=""
fi

if [ -n "$used_pct" ]; then
  # Round to integer
  used_int=$(printf "%.0f" "$used_pct")

  # Build a 20-char progress bar
  filled=$(( used_int * 20 / 100 ))
  empty=$(( 20 - filled ))
  bar=""
  for i in $(seq 1 $filled); do bar="${bar}█"; done
  for i in $(seq 1 $empty);  do bar="${bar}░"; done

  printf "\033[2m%s%s%s\033[0m  \033[2m[%s]\033[0m \033[2m%d%% used\033[0m" \
    "$version_prefix" "$model" "$effort_label" "$bar" "$used_int"
else
  printf "\033[2m%s%s%s\033[0m  \033[2m[░░░░░░░░░░░░░░░░░░░░]\033[0m \033[2m--%% used\033[0m" "$version_prefix" "$model" "$effort_label"
fi

# Rate limit usage (only shown when data is available)
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

rate_parts=""
if [ -n "$five_pct" ]; then
  five_int=$(printf "%.0f" "$five_pct")
  rate_parts="5h: ${five_int}%"
fi
if [ -n "$week_pct" ]; then
  week_int=$(printf "%.0f" "$week_pct")
  if [ -n "$rate_parts" ]; then
    rate_parts="${rate_parts}  7d: ${week_int}%"
  else
    rate_parts="7d: ${week_int}%"
  fi
fi

if [ -n "$rate_parts" ]; then
  printf "  \033[2m%s\033[0m" "$rate_parts"
fi
