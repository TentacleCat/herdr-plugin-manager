#!/usr/bin/env bash
# Runs every case in tests/cases. No network and no herdr: git, curl and the
# herdr CLI are all stubbed from tests/lib/stubs, and nothing outside the
# repo is read or written. Needs bash, python3 and perl.
#
#   bash tests/run.sh              # all cases
#   bash tests/run.sh bulk_loop    # just the cases whose name matches
set -uo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

filter="${1:-}"
failed=()
ran=0

for case_file in tests/cases/*.sh; do
  name="$(basename "$case_file" .sh)"
  [ -n "$filter" ] && case "$name" in *"$filter"*) ;; *) continue ;; esac
  printf '\n%s\n' "$name"
  ran=$(( ran + 1 ))
  bash "$case_file" || failed+=("$name")
done

if [ "$ran" -eq 0 ]; then
  printf '\nno cases matched %s\n' "${filter:-*}"
  exit 1
fi

printf '\n'
if [ "${#failed[@]}" -gt 0 ]; then
  printf 'FAILED: %s\n' "${failed[*]}"
  exit 1
fi
printf 'all %d case(s) passed\n' "$ran"
