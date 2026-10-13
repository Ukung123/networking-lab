# Lab 04: Dynamic routing with OSPF

```
                         r2  (lo 10.255.0.2)
            eth1 .2 /          \ eth2 .1
        10.0.12.0/30            10.0.23.0/30
           eth2 .1 /              \ eth2 .2
  h1 ---eth1 r1 ----------------------- r3 eth3--- h2
  .10    .1  (lo 10.255.0.1)  (lo 10.255.0.3)  .1   .10
  10.1.1.0/24   eth3 .1  10.0.13.0/30  eth1 .2     10.3.3.0/24
```

Three routers in a triangle, with a host on each end. Addresses are
configured and the OSPF daemon is running, but OSPF itself is not set up. In
Lab 03 you typed every route by hand; here the routers will work them out
themselves, and recover on their own when a link fails.

## Goals

- Enable OSPF and form neighbor adjacencies
- Read the OSPF neighbor table, database and routes
- Use passive interfaces and point-to-point network types
- Watch OSPF reroute around a failed link

## Concepts in two minutes

**OSPF** (Open Shortest Path First) is a **link-state** routing protocol.
Each router:

1. Says hello to routers on its links and forms **neighbor adjacencies**.
2. Floods a description of its links (**LSAs**) to every router in the area,
   so all routers build an identical map: the **link-state database**.
3. Runs Dijkstra's shortest path algorithm on that map and installs the best
   routes. The "length" of a path is the sum of interface **costs**.

Every router has a **router ID**, conventionally its loopback address.
Interfaces facing hosts should be **passive**: their network is advertised,
but no hellos are sent there (hosts don't speak OSPF, and it's safer).

FRR configuration looks like this:

```
router ospf
 ospf router-id 10.255.0.1
 network 10.0.0.0/8 area 0        ! run OSPF on every interface with a 10.x address
exit
interface eth1
 ip ospf passive                  ! advertise this LAN, but don't look for neighbors
exit
```

## Exercises

Start the lab: `make up LAB=04`

### 1. Configure OSPF on all three routers

On each router, in `vtysh` → `configure terminal`:

- create `router ospf` with the router ID from the diagram
- add `network 10.0.0.0/8 area 0`
- make the host-facing interface passive (r1 `eth1`, r3 `eth3`)

### 2. Watch the neighbors come up

```bash
vtysh -c "show ip ospf neighbor"
```

States go `Init → 2-Way → ExStart → Exchange → Loading → Full`. Run it a few
times. It can take **up to 40 seconds**.

<details><summary>Why so slow?</summary>

On a "broadcast" network type (the default for Ethernet) OSPF first elects a
Designated Router, and waits a full dead interval (40s) before deciding. Our
router-to-router links are point-to-point cables, so there's nothing to elect.
Tell OSPF that with `ip ospf network point-to-point` on each router-to-router
interface, and adjacencies form in a few seconds.
</details>

Set the router-to-router links to point-to-point, as the hint explains.

### 3. Read what OSPF learned

```bash
vtysh -c "show ip route ospf"       # routes OSPF installed (marked O)
vtysh -c "show ip ospf database"    # the shared map
vtysh -c "show ip ospf interface"   # costs, timers, passive or not
```

On r1, which way does it reach `10.3.3.0/24`, and what's the cost? From h1,
run `traceroute -n 10.3.3.10`.

### 4. Break a link

Keep a ping running from h1 to h2 (`ping 10.3.3.10`). In another terminal,
cut the direct r1 to r3 link:

```bash
docker exec clab-lab04-r1 ip link set eth3 down
```

How many pings are lost? Run `traceroute -n 10.3.3.10` again: which path now?
Bring the link back with `ip link set eth3 up` and watch traffic return.

### 5. Steer traffic with cost

With all links up, make r1 prefer the path through r2 by raising the cost of
its direct link: `interface eth3` → `ip ospf cost 100`. Confirm with traceroute.

## Check your work

```bash
make check LAB=04
```

## Going further

- On r2, set `ip ospf hello-interval 5` on one interface only. What happens to
  that adjacency, and why must timers match?
- Compare `show ip ospf database router` on all three routers. Are they identical?
