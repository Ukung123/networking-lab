#!/usr/bin/env bash
# Reference solution. Try the lab yourself first!
LAB_NAME=lab04
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab r1

vtysh r1 "configure terminal" \
  "router ospf" "ospf router-id 10.255.0.1" "network 10.0.0.0/8 area 0" "exit" \
  "interface eth1" "ip ospf passive" "exit" \
  "interface eth2" "ip ospf network point-to-point" "exit" \
  "interface eth3" "ip ospf network point-to-point"
vtysh r2 "configure terminal" \
  "router ospf" "ospf router-id 10.255.0.2" "network 10.0.0.0/8 area 0" "exit" \
  "interface eth1" "ip ospf network point-to-point" "exit" \
  "interface eth2" "ip ospf network point-to-point"
vtysh r3 "configure terminal" \
  "router ospf" "ospf router-id 10.255.0.3" "network 10.0.0.0/8 area 0" "exit" \
  "interface eth1" "ip ospf network point-to-point" "exit" \
  "interface eth2" "ip ospf network point-to-point" "exit" \
  "interface eth3" "ip ospf passive"
echo "Solution applied. Give OSPF ~10 seconds to converge, then run: make check LAB=04"
