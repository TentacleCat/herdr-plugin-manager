# Shared test helpers. Cases source this, then call check/report.
# Functions under test are lifted straight out of bin/manager.sh so the
# assertions run against shipping code, not a copy.

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
stubs="$root/tests/lib/stubs"
fixtures="$root/tests/fixtures"

pass=0
fail=0

# Prints one top-level function definition from bin/manager.sh.
#   $1 function name
extract_fn() {
  awk -v fn="$1" '$0 ~ "^"fn"\\(\\) \\{" {p=1} p{print} p && /^\}$/{exit}' \
    "$root/bin/manager.sh"
}

# Sources the named functions into the current shell.
load_fns() {
  local fn src=""
  for fn in "$@"; do
    src+="$(extract_fn "$fn")"$'\n'
  done
  eval "$src"
}

#   $1 description  $2 expected  $3 actual
check() {
  if [ "$2" = "$3" ]; then
    pass=$(( pass + 1 ))
    printf '  ok   %s\n' "$1"
  else
    fail=$(( fail + 1 ))
    printf '  FAIL %s\n         expected: [%s]\n         actual:   [%s]\n' "$1" "$2" "$3"
  fi
}

report() {
  printf '  %d passed, %d failed\n' "$pass" "$fail"
  [ "$fail" -eq 0 ]
}
