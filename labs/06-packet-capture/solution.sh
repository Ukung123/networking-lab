#!/usr/bin/env bash
# Reference solution. Try the lab yourself first!
LAB_NAME=lab06
DIR="$(dirname "$0")"
source "$DIR/../../scripts/lib.sh"
require_lab h1

# 1. ARP: forget the gateway's MAC, then capture the lookup
run h1 ip neigh flush dev eth1
docker exec -d "$(node h1)" timeout 4 tcpdump -i eth1 -n arp -w /captures/arp.pcap
sleep 1; run h1 ping -c 1 10.6.1.1 >/dev/null

# 2. TTL: h1 sends with TTL 64; r1 decrements it, so srv sees 63
docker exec -d "$(node srv)" timeout 4 tcpdump -i eth1 -n icmp -w /captures/ttl.pcap
sleep 1; run h1 ping -c 2 10.6.2.80 >/dev/null

# 3. TCP handshake and HTTP, captured on srv
docker exec -d "$(node srv)" timeout 4 tcpdump -i eth1 -n tcp port 80 -w /captures/http.pcap
sleep 1; run h1 curl -s http://10.6.2.80/ >/dev/null
sleep 4

# 4. Read the page out of the capture
run h1 tshark -r /captures/http.pcap -q -z follow,tcp,ascii,0 | grep -o 'flag=[a-z-]*' | head -1 > "$DIR/answers.txt"
echo "Solution applied. Run: make check LAB=06"
