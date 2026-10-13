#!/usr/bin/env bash
# Reference solution. Try the lab yourself first!
LAB_NAME=lab05
DIR="$(dirname "$0")"
source "$DIR/../../scripts/lib.sh"
require_lab srv

grep -q '^dhcp-host=h2,' "$DIR/srv/dnsmasq.conf" || echo 'dhcp-host=h2,10.5.0.42' >> "$DIR/srv/dnsmasq.conf"
grep -q 'db$' "$DIR/srv/lab.hosts" || echo '10.5.0.53   db' >> "$DIR/srv/lab.hosts"
bash "$DIR/reload-dns.sh"

run h1 udhcpc -i eth1 -n -q 2>&1 | grep -v resolv.conf
run h2 udhcpc -i eth1 -n -q -x hostname:h2 2>&1 | grep -v resolv.conf
# Docker owns /etc/resolv.conf, so udhcpc can't replace it; write it ourselves
run h1 sh -c 'printf "nameserver 10.5.0.2\nsearch lab.local\n" > /etc/resolv.conf'
echo "Solution applied. Run: make check LAB=05"
