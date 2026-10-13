#!/usr/bin/env bash
LAB_NAME=lab04
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab r1

full_neighbors() { # <router> <count>
  [ "$(docker exec "$(node "$1")" vtysh -c 'show ip ospf neighbor' | grep -c Full)" -ge "$2" ]
}
ospf_route() { docker exec "$(node "$1")" vtysh -c "show ip route $2" | grep -q 'Known via "ospf"'; }

echo "Lab 04: Dynamic routing with OSPF"
check "r1 has 2 OSPF neighbors in Full state"   full_neighbors r1 2
check "r2 has 2 OSPF neighbors in Full state"   full_neighbors r2 2
check "r3 has 2 OSPF neighbors in Full state"   full_neighbors r3 2
check "r1 learned 10.3.3.0/24 from OSPF"        ospf_route r1 10.3.3.0/24
check "r3 learned 10.1.1.0/24 from OSPF"        ospf_route r3 10.1.1.0/24
check "r2 learned r1's loopback 10.255.0.1/32"  ospf_route r2 10.255.0.1/32
check "h1 reaches h2 (10.3.3.10)"               ping_ok h1 10.3.3.10
check "OSPF hellos are not sent toward the hosts (eth1 on r1 is passive)" \
  sh -c "docker exec $(node r1) vtysh -c 'show ip ospf interface eth1' | grep -qi passive"
summary
