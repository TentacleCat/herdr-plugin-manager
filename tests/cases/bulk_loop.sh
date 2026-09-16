#!/usr/bin/env bash
# How the batch drives its installs, with herdr itself stubbed out.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/harness.sh"
load_fns do_update_all

bold="" dim="" green="" yellow="" red="" reset=""
have_git=1
checked=1
msg=""

outdated_rows() {
  printf 'p1\tAlpha\tex/alpha\tmain\n'
  printf 'p2\tBravo\tex/bravo\t-\n'
  printf 'p3\tCharlie\tex/charlie\tv2.0.0\n'
}
plugin_update_version() { printf '9.9.9'; }
pause_key() { :; }
load_plugins() { :; }
run_update_checks() { :; }

calls=""
run_herdr() {
  calls+="$* | "
  [ -n "$decline" ] && [ "$3" = "$decline" ] && return 1
  return 0
}

# A here-string, not a pipe: a pipe would run do_update_all in a subshell and
# lose both $msg and $calls.
run_batch() { calls=""; msg=""; do_update_all >/dev/null <<< "$1"; }

decline=""
run_batch y
check "every plugin installed, requested ref preserved" \
  "plugin install ex/alpha --ref main | plugin install ex/bravo | plugin install ex/charlie --ref v2.0.0 | " \
  "$calls"
check "all-succeeded message" "✓ updated 3 plugin(s)" "$msg"

decline="ex/bravo"
run_batch y
check "a declined preview does not stop the batch" \
  "plugin install ex/alpha --ref main | plugin install ex/bravo | plugin install ex/charlie --ref v2.0.0 | " \
  "$calls"
check "declines are counted, not fatal" "updated 2 of 3 — 1 declined or failed" "$msg"

decline=""
run_batch n
check "declining the confirm installs nothing" "" "$calls"
check "cancelled message" "bulk update cancelled" "$msg"

checked=0
run_batch y
check "batch refuses to run before the checks land" "" "$calls"
check "still-checking message" "still checking for updates — try again in a moment" "$msg"

checked=1
have_git=0
run_batch y
check "batch refuses to run without git" "" "$calls"
check "no-git message" "install git to check for updates" "$msg"

have_git=1
outdated_rows() { :; }
run_batch y
check "nothing behind installs nothing" "" "$calls"
check "nothing-to-update message" "✓ nothing to update" "$msg"

report
