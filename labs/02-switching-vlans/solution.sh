#!/usr/bin/env bash
# Reference solution. Try the lab yourself first!
LAB_NAME=lab02
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab sw2

run sw2 bridge vlan del dev eth1 vid 1
run sw2 bridge vlan add dev eth1 vid 10 pvid untagged
run sw2 bridge vlan del dev eth2 vid 1
run sw2 bridge vlan add dev eth2 vid 20 pvid untagged
run sw2 bridge vlan del dev eth3 vid 1
run sw2 bridge vlan add dev eth3 vid 10
run sw2 bridge vlan add dev eth3 vid 20
echo "Solution applied. Run: make check LAB=02"
