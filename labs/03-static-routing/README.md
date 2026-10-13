# Lab 03: Static routing

```
  h1 ------- r1 ---------------- r2 ---------------- r3 ------- h2
  .10   eth1 .1  eth2 .1   eth1 .2  eth2 .1   eth1 .2  eth2 .1   .10
  10.1.1.0/24     10.0.12.0/30         10.0.23.0/30      10.3.3.0/24
```

Every interface has its address, but the routers know only their directly
connected networks. Your job: teach them the rest, by hand.

Each host already sends everything in `10.0.0.0/8` to its nearest router.

## Goals

- Read a routing table and predict where a packet goes
- Add static routes with the FRR command line
- Understand that a packet needs a route **there and back**
- Use a summary route and see longest-prefix matching in action

## Concepts in two minutes

A router forwards each packet by looking up the destination in its **routing
table** and picking the **most specific** (longest prefix) matching entry.
Directly connected networks are added automatically; everything else must be
learned, either by hand (**static routes**, this lab) or from other routers
(**dynamic routing**, next lab).

A static route says "to reach network X, send to next hop Y":

```
ip route 10.3.3.0/24 10.0.12.2
```

The next hop must be on a network the router is directly connected to.

The routers run FRR. Its CLI, `vtysh`, looks and feels like Cisco IOS:

```bash
make shell LAB=03 NODE=r1
vtysh
r1# show ip route
r1# configure terminal
r1(config)# ip route 10.3.3.0/24 10.0.12.2
r1(config)# end
r1# show ip route static
r1# write memory          # optional: save the config
```

## Exercises

Start the lab: `make up LAB=03`

### 1. Read the tables

On each router run `show ip route` and list what it already knows. Lines
starting with `C` are connected networks. Which networks can r1 reach right now?

### 2. The forward path only

On **r1** and **r2** add routes toward `10.3.3.0/24` (h2's network). Then
from h1: `ping -c 3 10.3.3.10`. It still fails!

<details><summary>Hint</summary>

The ping reaches h2. h2 replies to `10.1.1.10`. Follow the reply: h2 sends it
to r3. Does r3 know where `10.1.1.0/24` is? Run `show ip route 10.1.1.10` on r3.
</details>

### 3. The return path

- On **r2**, add a route to `10.1.1.0/24` via r1.
- On **r3**, instead of listing every network, add one **summary route**:
  `10.0.0.0/8` via r2. It covers every lab network in one line.

Ping again. Then run `traceroute -n 10.3.3.10` from h1 and count the hops.

### 4. Longest prefix wins

r3 now has `10.0.0.0/8` via r2, and also its connected `10.3.3.0/24`. For a
packet to `10.3.3.10`, both match. Which one does r3 use, and why? Check with
`show ip route 10.3.3.10`.

### 5. Make r1 reach every link

From h1, `ping 10.0.23.2` (r3's far interface). If it fails, which router is
missing a route? Fix it.

## Check your work

```bash
make check LAB=03
```

## Going further

- Replace r1's specific routes with one summary route. What do you lose?
- Add a route on r2 that points the wrong way (to r1 for `10.3.3.0/24`) and run
  a traceroute. What does a **routing loop** look like?
- Why did we use a `10.0.0.0/8` summary on r3 and not a default route
  (`0.0.0.0/0`)? Look at `show ip route 0.0.0.0/0` on r3: who already owns the
  default route? (Hint: eth0.)
