# Lab 02: Switching, VLANs and trunks

```
  VLAN 10 (10.10.10.0/24)   h1 .11 --eth1+              +eth1-- h2 .12
                                         sw1 ==eth3== sw2
  VLAN 20 (10.20.20.0/24)   h3 .13 --eth2+   ||        +eth2-- h4 .14
                                            eth4  (trunk)
                                             ||
                                             r1  eth1.10 = 10.10.10.1
                                                 eth1.20 = 10.20.20.1
```

sw1 is fully configured. **sw2 is a plain switch with no VLANs**, and
configuring it is your job. r1 routes between the two VLANs
("router on a stick").

The switches are Linux bridges with VLAN filtering turned on, the same
technology inside many real switches and every Linux hypervisor.

## Goals

- Explain what a VLAN is and why it splits one switch into several
- Configure **access ports** (one untagged VLAN) and **trunk ports** (many tagged VLANs)
- See the 802.1Q tag on the wire
- Route between VLANs with a router on a stick

## Concepts in two minutes

A switch forwards frames by MAC address within one **broadcast domain**. A
**VLAN** splits a switch into several separate broadcast domains: a host in
VLAN 10 never sees frames from VLAN 20, as if they were on different switches.

- An **access port** belongs to one VLAN. Frames leave it untagged; the host
  doesn't know VLANs exist.
- A **trunk port** carries many VLANs over one cable. Each frame gets a
  4-byte **802.1Q tag** with its VLAN number, so the switch at the other end
  knows where it belongs.
- Hosts in different VLANs are in different subnets, so a **router** must
  move traffic between them. With one trunk to the router, the router uses one
  sub-interface per VLAN (`eth1.10`, `eth1.20`).

On a Linux bridge:

```bash
bridge vlan show                                  # VLANs on every port
bridge vlan add dev eth1 vid 10 pvid untagged     # access port in VLAN 10
bridge vlan add dev eth3 vid 10                   # allow VLAN 10, tagged, on a trunk
bridge vlan del dev eth1 vid 1                    # remove the default VLAN 1
```

`pvid` means "untagged frames arriving here belong to this VLAN", and
`untagged` means "strip the tag when sending out of this port".

## Exercises

Start the lab: `make up LAB=02`

### 1. Study the finished switch

```bash
make shell LAB=02 NODE=sw1
bridge vlan show
```

Which ports are access ports and which are trunks? How can you tell?

### 2. Prove that sw2 is broken

From h1, `ping -c 3 10.10.10.12` (h2, same VLAN, other switch). It fails.
Then on sw2 run `bridge vlan show`.

<details><summary>Hint</summary>

Every sw2 port is in VLAN 1 only. sw1 sends VLAN 10 frames over the trunk
tagged with VLAN 10. What does sw2 do with a tag it isn't configured for?
</details>

### 3. Configure sw2

On sw2, make:

- `eth1` (h2) an access port in VLAN 10
- `eth2` (h4) an access port in VLAN 20
- `eth3` (to sw1) a trunk carrying VLANs 10 and 20 tagged

Remove VLAN 1 from all three ports. Then ping h2 from h1 and h4 from h3.

### 4. See the tags

While h1 pings h2, capture on the trunk:

```bash
make shell LAB=02 NODE=sw1
tcpdump -i eth3 -e -n icmp
```

`-e` prints the Ethernet header. Look for `vlan 10`. Now capture on `eth1`
(h1's access port) instead: is the tag there?

### 5. Route between VLANs

From h2, `ping 10.20.20.14` (h4, other VLAN). The packet goes h2 → sw2 → sw1
→ r1 (VLAN 10 sub-interface) → r1 (VLAN 20 sub-interface) → sw1 → sw2 → h4.
Confirm it with `traceroute -n 10.20.20.14` from h2, then look at r1:

```bash
make shell LAB=02 NODE=r1
vtysh -c "show interface brief"
vtysh -c "show ip route"
```

## Check your work

```bash
make check LAB=02
```

## Going further

- Add VLAN 30 end to end: a new host on sw2, a new sub-interface `eth1.30` on r1
  (`ip link add link eth1 name eth1.30 type vlan id 30`, then give it an address
  in `vtysh`), and allow VLAN 30 on both trunks.
- Remove VLAN 20 from the sw1 to sw2 trunk only. Which pings break, and which still work?
