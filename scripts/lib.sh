#!/usr/bin/env bash
# Helpers shared by every lab's check.sh and solution.sh.
# Each lab sets LAB_NAME (the `name:` in its topology file) before sourcing this.

PASS=0
FAIL=0

node() { echo "clab-${LAB_NAME}-$1"; }

# run <node> <command...>   run a command inside a lab node
run() { local n=$1; shift; docker exec "$(node "$n")" "$@"; }

# vtysh <node> <command...>   run FRR commands on a router (each arg is one line)
vtysh() {
  local n=$1; shift
  local args=()
  for c in "$@"; do args+=(-c "$c"); done
  run "$n" vtysh "${args[@]}"
}

# check "<description>" <command...>   passes if the command exits 0
check() {
  local desc=$1; shift
  if "$@" >/dev/null 2>&1; then
    echo "  ✅ $desc"; PASS=$((PASS + 1))
  else
    echo "  ❌ $desc"; FAIL=$((FAIL + 1))
  fi
}

ping_ok() { run "$1" ping -c 2 -W 2 "$2"; }

require_lab() {
  if ! docker inspect "$(node "$1")" >/dev/null 2>&1; then
    echo "Lab '${LAB_NAME}' is not running. Start it with: make up LAB=${LAB_NAME#lab}"
    exit 2
  fi
}

summary() {
  echo
  if [ "$FAIL" -eq 0 ]; then
    echo "🎉 All $PASS checks passed."
  else
    echo "$PASS passed, $FAIL failed. Re-read the hints in the lab README and try again."
    exit 1
  fi
}
