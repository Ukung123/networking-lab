#!/usr/bin/env bash
# Reference solution. Try the lab yourself first!
LAB_NAME=lab03
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab r1

vtysh r1 "configure terminal" \
  "ip route 10.3.3.0/24 10.0.12.2" \
  "ip route 10.0.23.0/30 10.0.12.2"
vtysh r2 "configure terminal" \
  "ip route 10.1.1.0/24 10.0.12.1" \
  "ip route 10.3.3.0/24 10.0.23.2"
vtysh r3 "configure terminal" \
  "ip route 10.0.0.0/8 10.0.23.1"
echo "Solution applied. Run: make check LAB=03"
