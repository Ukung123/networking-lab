#!/usr/bin/env bash
LAB_NAME=lab06
DIR="$(dirname "$0")"
source "$DIR/../../scripts/lib.sh"
require_lab h1

# count <pcap> <display filter>  -> number of matching packets (tshark runs inside h1)
count() { docker exec "$(node h1)" tshark -r "/captures/$1" -Y "$2" 2>/dev/null | wc -l; }
has() { [ "$(count "$1" "$2")" -gt 0 ]; }

echo "Lab 06: Packet capture"
check "captures/arp.pcap has an ARP request"              has arp.pcap 'arp.opcode == 1'
check "captures/arp.pcap has an ARP reply"                has arp.pcap 'arp.opcode == 2'
check "captures/ttl.pcap (taken on srv) has echo requests with TTL 63" has ttl.pcap 'icmp.type == 8 && ip.ttl == 63'
check "captures/http.pcap has the TCP SYN"                has http.pcap 'tcp.flags.syn == 1 && tcp.flags.ack == 0'
check "captures/http.pcap has the SYN/ACK"                has http.pcap 'tcp.flags.syn == 1 && tcp.flags.ack == 1'
check "captures/http.pcap has an HTTP GET"                has http.pcap 'http.request.method == "GET"'
check "answers.txt has the flag hidden in the HTTP page" \
  sh -c "grep -qx 'flag=cleartext-is-readable' '$DIR/answers.txt'"
summary
