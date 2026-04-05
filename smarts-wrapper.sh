#!/usr/bin/env bash
set -euo pipefail

smarts_cmd=("$SMARTS_HOME/smarts295bat" "$@")

echo "pwd:"
pwd

echo
echo "ls -l:"
ls -l

echo
echo "ls -l /work:"
ls -l /work

echo
printf 'About to run:'
printf ' %q' "${smarts_cmd[@]}"
printf '\n'

exec "${smarts_cmd[@]}"
