#!/usr/bin/env bash
# The config key follows the explicit override, then VISUAL, then EDITOR.
source "$(dirname "${BASH_SOURCE[0]}")/../lib/harness.sh"
load_fns do_plugins_json

plugins_json="$(mktemp)"
trap 'rm -f "$plugins_json"' EXIT
dry_run=0
red="" green="" yellow="" reset=""
msg=""
opened_by=""
opened_file=""

nvim() { opened_by=nvim; opened_file=$1; }
vim() { opened_by=vim; opened_file=$1; }
code() { opened_by=code; opened_file=$1; }

unset HERDR_PM_EDITOR VISUAL
EDITOR=nvim
do_plugins_json
check "EDITOR selects nvim" nvim "$opened_by"
check "EDITOR gets the registry path" "$plugins_json" "$opened_file"

VISUAL=vim
opened_by=""
do_plugins_json
check "VISUAL wins over EDITOR" vim "$opened_by"

HERDR_PM_EDITOR=code
opened_by=""
do_plugins_json
check "explicit override wins" code "$opened_by"

report
