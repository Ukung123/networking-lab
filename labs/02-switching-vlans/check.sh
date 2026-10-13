#!/usr/bin/env bash
LAB_NAME=lab02
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab sw2

vlan_has() { # <node> <port> <regex>
  docker exec "$(node "$1")" bridge vlan show dev "$2" | grep -Eq "$3"
}

echo "Lab 02: Switching, VLANs and trunks"
check "sw2 eth1 is an access port in VLAN 10"  vlan_has sw2 eth1 '\b10 PVID Egress Untagged'
check "sw2 eth2 is an access port in VLAN 20"  vlan_has sw2 eth2 '\b20 PVID Egress Untagged'
check "sw2 eth3 carries VLAN 10 tagged"        sh -c "docker exec $(node sw2) bridge vlan show dev eth3 | grep -E '\b10\b' | grep -vq Untagged"
check "sw2 eth3 carries VLAN 20 tagged"        sh -c "docker exec $(node sw2) bridge vlan show dev eth3 | grep -E '\b20\b' | grep -vq Untagged"
check "h1 reaches h2 across the trunk (VLAN 10)" ping_ok h1 10.10.10.12
check "h3 reaches h4 across the trunk (VLAN 20)" ping_ok h3 10.20.20.14
check "h2 reaches its gateway r1 (10.10.10.1)"   ping_ok h2 10.10.10.1
check "h2 reaches h4 through r1 (inter-VLAN)"    ping_ok h2 10.20.20.14
summary
