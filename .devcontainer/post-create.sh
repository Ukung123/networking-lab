#!/usr/bin/env bash
# Runs once when the Codespace (or local dev container) is created.
set -euo pipefail

echo "==> Waiting for Docker"
for _ in $(seq 1 30); do docker info >/dev/null 2>&1 && break; sleep 2; done

echo "==> Installing Containerlab"
bash -c "$(curl -sL https://get.containerlab.dev)"

echo "==> Pre-pulling lab images"
for img in nicolaka/netshoot:v0.13 frrouting/frr:v8.4.1 4km3/dnsmasq:2.90-r3-alpine-3; do
  docker pull -q "$img"
done

echo "==> Ready. Start with: make up LAB=01"
