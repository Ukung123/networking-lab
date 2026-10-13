#!/usr/bin/env bash
LAB_NAME=lab01
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab h1

echo "Lab 01: IP addressing and subnets"
check "h1 can reach h2 (192.168.1.20)"            ping_ok h1 192.168.1.20
check "h3 uses a /24 mask"                        sh -c "docker exec $(node h3) ip -4 addr show eth1 | grep -q '192.168.1.130/24'"
check "h1 can reach h3 (192.168.1.130)"           ping_ok h1 192.168.1.130
check "h4 has 192.168.1.40/24 on eth1"            sh -c "docker exec $(node h4) ip -4 addr show eth1 | grep -q '192.168.1.40/24'"
check "h4 can reach h1 (192.168.1.10)"            ping_ok h4 192.168.1.10
check "answers.txt: broadcast of 192.168.1.130/25" sh -c "grep -qx 'broadcast=192.168.1.255' $(dirname "$0")/answers.txt"
check "answers.txt: usable hosts in a /26"        sh -c "grep -qx 'hosts26=62' $(dirname "$0")/answers.txt"
check "answers.txt: network of 10.20.30.77/27"    sh -c "grep -qx 'network=10.20.30.64' $(dirname "$0")/answers.txt"
summary
