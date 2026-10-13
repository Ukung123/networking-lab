#!/usr/bin/env bash
LAB_NAME=lab03
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab r1

has_static() { docker exec "$(node "$1")" vtysh -c "show ip route $2" | grep -q 'Known via "static"'; }

echo "Lab 03: Static routing"
check "r1 has a static route to 10.3.3.0/24"      has_static r1 10.3.3.0/24
check "r2 has a static route to 10.1.1.0/24"      has_static r2 10.1.1.0/24
check "r2 has a static route to 10.3.3.0/24"      has_static r2 10.3.3.0/24
check "r3 has a static summary route to 10.0.0.0/8" has_static r3 10.0.0.0/8
check "h1 reaches r3's far side (10.0.23.2)"      ping_ok h1 10.0.23.2
check "h1 reaches h2 (10.3.3.10)"                 ping_ok h1 10.3.3.10
check "h2 reaches h1 (10.1.1.10)"                 ping_ok h2 10.1.1.10
summary
