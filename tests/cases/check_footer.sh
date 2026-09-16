#!/usr/bin/env bash
# The footer only advertises [U] once more than one plugin is behind.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/harness.sh"
load_fns check_footer

buf=""
put() { local s; printf -v s "$@"; buf+="$s"; }
dim="" yellow="" reset=""
statusfile="$(mktemp)"
trap 'rm -f "$statusfile"' EXIT
have_git=1
checked=1
rows=(one)

footer() { buf=""; check_footer; printf '%s' "${buf//$'\n'/}"; }

printf 'a\tcurrent\n' > "$statusfile"
check "nothing behind" "  all plugins up to date" "$(footer)"

printf 'a\tupdate\n' > "$statusfile"
check "one behind points at [u]" \
  "  ↑ 1 update available — press [u] to update" "$(footer)"

printf 'a\tupdate\nb\tupdate\nc\tupdate\n' > "$statusfile"
check "several behind point at [U]" \
  "  ↑ 3 updates available — [u] this row · [U] all" "$(footer)"

have_git=0
check "no git" "  install git to check for updates" "$(footer)"

have_git=1
checked=0
check "still checking" "  checking for updates…" "$(footer)"

report
