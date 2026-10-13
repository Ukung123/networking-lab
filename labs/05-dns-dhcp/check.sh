#!/usr/bin/env bash
LAB_NAME=lab05
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab srv

addr_of() { docker exec "$(node "$1")" ip -4 -o addr show eth1 | awk '{print $4}' | cut -d/ -f1; }
in_pool() { local a; a=$(addr_of "$1"); [[ "$a" =~ ^10\.5\.0\.([0-9]+)$ ]] && (( BASH_REMATCH[1] >= 100 && BASH_REMATCH[1] <= 150 )); }

echo "Lab 05: DHCP and DNS"
check "h1 got an address from the DHCP pool (10.5.0.100-150)" in_pool h1
check "h1 resolves web.lab.local to 10.5.0.80" \
  sh -c "[ \"\$(docker exec $(node h1) dig +short web.lab.local @10.5.0.2)\" = 10.5.0.80 ]"
check "h1 pings web by its short name (via DNS from srv)" \
  sh -c "docker exec $(node h1) ping -c1 -W2 web | head -1 | grep -q 10.5.0.80"
check "h2 got its reserved address 10.5.0.42" \
  sh -c "[ \"$(addr_of h2)\" = 10.5.0.42 ]"
check "you added db.lab.local -> 10.5.0.53" \
  sh -c "[ \"\$(docker exec $(node h1) dig +short db.lab.local @10.5.0.2)\" = 10.5.0.53 ]"
check "reverse lookup of 10.5.0.80 gives web.lab.local" \
  sh -c "docker exec $(node h1) dig +short -x 10.5.0.80 @10.5.0.2 | grep -q '^web.lab.local.$'"
summary
