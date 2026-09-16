#!/usr/bin/env bash
# Drives the real popup end to end with git, curl and herdr all stubbed, so
# the run is offline and deterministic. Fixture set: alpha names a branch,
# bravo names no ref at all, charlie an annotated tag (whose peeled sha is
# what should be compared), delta is already current, echo is pinned to an
# exact sha and foxtrot is a local link — so the batch picks up exactly
# three, and each keeps its own ref.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/harness.sh"

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
log="$work/installs.log"
: > "$log"

# Keys: [U] batch, y to confirm, one key for the pause, q to quit.
out="$(printf 'Uy q' | \
  PATH="$stubs:$PATH" \
  HERDR_BIN_PATH="$stubs/herdr" \
  HERDR_SOCKET_PATH="$work/herdr.sock" \
  STUB_PLUGINS="$fixtures/plugins.json" \
  STUB_REMOTE="$fixtures/remote.tsv" \
  STUB_VERSIONS="$fixtures/versions.tsv" \
  STUB_LOG="$log" \
  STUB_DECLINE="ex/bravo" \
  perl -e 'alarm 90; exec @ARGV' -- bash "$root/bin/manager.sh" 2>&1 \
  | sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g; s/(B//g')"

has() { case "$out" in *"$1"*) printf yes ;; *) printf no ;; esac; }

check "the three outdated plugins are offered" "yes" "$(has 'updating 3 plugin(s):')"
check "target version read from the remote manifest" "yes" "$(has 'Alpha → 0.3.5')"
check "annotated tag resolves to its peeled commit" "yes" "$(has 'Charlie → 2.0.0')"
check "confirm names the count" "yes" "$(has 'update 3 plugin(s)? [y/N]')"
check "already-current plugin left out" "no" "$(has 'Delta →')"
check "exact-sha pin left out" "no" "$(has 'Echo →')"
check "local link left out" "no" "$(has 'Foxtrot →')"

check "all three installs issued" \
  "install: ex/alpha --ref main
install: ex/bravo
install: ex/charlie --ref v2.0.0" \
  "$(cat "$log")"

check "declined plugin counted, batch finished" "yes" \
  "$(has 'updated 2 of 3 — 1 declined or failed')"

report
