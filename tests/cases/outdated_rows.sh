#!/usr/bin/env bash
# Which plugins a bulk update picks up.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/harness.sh"
load_fns is_sha_pin plugin_status plugin_update_version outdated_rows

statusfile="$(mktemp)"
trap 'rm -f "$statusfile"' EXIT

# id name ver enabled kind spec commit slug ref full
row() { printf '%s\t%s\t1.0\t1\t%s\t%s\tc\t%s\t%s\t%s\n' "$1" "$1" "$2" "$3" "$3" "$4" "$5"; }
ids() { outdated_rows | cut -f1 | tr '\n' ' ' | sed 's/ $//'; }

rows=(
  "$(row gh-update  github owner/a main aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)"
  "$(row gh-current github owner/b main bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb)"
  "$(row gh-error   github owner/c main cccccccccccccccccccccccccccccccccccccccc)"
  "$(row linked     link   owner/d -    dddddddddddddddddddddddddddddddddddddddd)"
)
printf 'gh-update\tupdate\t2.0\ngh-current\tcurrent\ngh-error\terror\nlinked\tupdate\n' > "$statusfile"
check "only github rows checked as outdated" "gh-update" "$(ids)"

rows=(
  "$(row pinned github owner/a aaaaaaa aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)"
  "$(row branch github owner/b main    bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb)"
  "$(row noref  github owner/c -       cccccccccccccccccccccccccccccccccccccccc)"
  "$(row tagged github owner/d v1.2.3  dddddddddddddddddddddddddddddddddddddddd)"
)
printf 'pinned\tupdate\nbranch\tupdate\nnoref\tupdate\ntagged\tupdate\n' > "$statusfile"
check "exact-sha pin passed over, ref/branch/tag kept" "branch noref tagged" "$(ids)"

rows=(
  "$(row sha-shaped github owner/a abcdef1234 ffffffffffffffffffffffffffffffffffffffff)"
)
printf 'sha-shaped\tupdate\n' > "$statusfile"
check "hex ref that is not this commit's prefix is no pin" "sha-shaped" "$(ids)"

rows=()
: > "$statusfile"
check "no plugins" "" "$(ids)"

rows=("$(row only github owner/a main aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa)")
: > "$statusfile"
check "checks not in yet" "" "$(ids)"

report
