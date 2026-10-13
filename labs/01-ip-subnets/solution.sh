#!/usr/bin/env bash
# Reference solution. Try the lab yourself first!
LAB_NAME=lab01
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab h1

run h3 ip addr del 192.168.1.130/25 dev eth1 2>/dev/null
run h3 ip addr replace 192.168.1.130/24 dev eth1
run h4 ip addr replace 192.168.1.40/24 dev eth1
cat > "$(dirname "$0")/answers.txt" <<'ANS'
broadcast=192.168.1.255
hosts26=62
network=10.20.30.64
ANS
echo "Solution applied. Run: make check LAB=01"
