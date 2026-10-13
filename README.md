# Networking Fundamentals Lab

A hands-on lab for learning how networks really work, by building and breaking
small virtual networks. Everything is free and open source: the routers are
[FRRouting](https://frrouting.org/), the hosts are Linux containers, and
[Containerlab](https://containerlab.dev/) wires them together.

No cloud account is needed. Run it in **GitHub Codespaces** (free monthly hours
on every GitHub account) or on any Linux machine with Docker.

## The labs

| # | Lab | You will learn to |
|---|-----|-------------------|
| 01 | [IP addressing and subnets](labs/01-ip-subnets/) | read addresses and masks, find a mask mismatch, do subnet math |
| 02 | [Switching, VLANs and trunks](labs/02-switching-vlans/) | configure access and trunk ports, see 802.1Q tags, route between VLANs |
| 03 | [Static routing](labs/03-static-routing/) | build routing tables by hand and debug the return path |
| 04 | [Dynamic routing with OSPF](labs/04-ospf/) | bring up OSPF neighbors, read the routing table, watch failover |
| 05 | [DHCP and DNS](labs/05-dns-dhcp/) | watch the DHCP handshake, reserve addresses, run your own DNS zone |
| 06 | [Packet capture](labs/06-packet-capture/) | capture ARP, ICMP and TCP with tcpdump, and read HTTP out of a capture |

Do them in order: each lab assumes the earlier ones.

## Getting started

### Option A: GitHub Codespaces (recommended)

1. On this repository's GitHub page, click **Code → Codespaces → Create codespace on main**.
2. Wait for setup to finish (the first time takes a few minutes; it installs
   Containerlab and downloads the lab images).
3. In the terminal:

   ```bash
   make up LAB=01        # start lab 01
   ```

Stop the codespace when you're done (**Codespaces → Stop**) so it doesn't use
up your free hours.

### Option B: your own Linux machine

You need Docker and Containerlab:

```bash
bash -c "$(curl -sL https://get.containerlab.dev)"
git clone <this repo> && cd <this repo>
make up LAB=01
```

On Windows use WSL2; on macOS, Codespaces is the easiest route.

## How every lab works

```bash
make up    LAB=01           # start the lab's network
make shell LAB=01 NODE=h1   # get a shell on node h1 (routers: type `vtysh` for the router CLI)
exit                        # leave the node's shell and return to the Codespace
make check LAB=01           # grade your work: ✅ / ❌ for each goal
make reset LAB=01           # broke something? start over
make down  LAB=01           # stop the lab
make solve LAB=01           # stuck? apply the reference solution (try first!)
```

`make` only works in the Codespace's own terminal, the one whose prompt shows
`/workspaces/networking-lab`. Inside a node (prompt like `h1:~#`) there is no
`make`: type `exit` first.

Each lab folder has:

- `README.md`: the concepts, the exercises and hints
- `topology.clab.yml`: the network diagram as code (read it, it's short)
- `check.sh`: the grader that `make check` runs
- `solution.sh`: the reference answer

### One thing to know before you start

Every node has an extra interface, **eth0**, on the `172.20.20.0/24`
management network. Containerlab uses it to manage the nodes; it's not part of
the lab. Your lab links are **eth1, eth2, ...** Always use the lab addresses
from the diagram, never the 172.20.20.x ones, or your pings will take a
shortcut around the network you're studying.

## What's next

This repo is the first part of a bigger path: networking, then cloud
computing, then cybersecurity. Cloud and security labs will build on the
skills practised here.
