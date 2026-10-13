#!/usr/bin/env bash
# Restart dnsmasq so it rereads srv/dnsmasq.conf and srv/lab.hosts.
LAB_NAME=lab05
source "$(dirname "$0")/../../scripts/lib.sh"
require_lab srv

run srv sh -c 'pkill dnsmasq; sleep 1; dnsmasq --conf-file=/etc/dnsmasq.d/dnsmasq.conf' \
  && echo "dnsmasq reloaded." \
  || { echo "dnsmasq failed to start. Check your edits:"; run srv dnsmasq --test --conf-file=/etc/dnsmasq.d/dnsmasq.conf; }
