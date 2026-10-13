# Lab 01: IP addressing and subnets

```
     h1 .10      h2 .20      h3 .130     h4 (you)
       |           |           |           |
   +------------------- sw --------------------+
                  192.168.1.0/24
```

Four hosts share one switch. Three already have addresses; one of those is
misconfigured, and h4 has nothing at all.

## Goals

- Read an interface's address and prefix length
- Explain how a host decides "is this destination on my subnet?"
- Find and fix a subnet mask mismatch
- Work out network, broadcast and host counts for any prefix

## Concepts in two minutes

An address like `192.168.1.10/24` has two parts. The **prefix length** (`/24`)
says how many leading bits are the **network**; the rest identify the **host**.

| Prefix | Mask | Addresses | Usable hosts |
|--------|------|-----------|--------------|
| /24 | 255.255.255.0 | 256 | 254 |
| /25 | 255.255.255.128 | 128 | 126 |
| /26 | 255.255.255.192 | 64 | 62 |
| /27 | 255.255.255.224 | 32 | 30 |
| /30 | 255.255.255.252 | 4 | 2 |

Usable = total minus 2: the first address names the network and the last is
the broadcast.

When a host sends a packet it asks: *is the destination inside my own
subnet?* If yes, it uses ARP to find the destination's MAC address and sends
directly. If no, it hands the packet to a router (its gateway). **Each side
answers that question with its own mask**, so if two neighbours disagree about
the mask, traffic can work in one direction and fail in the other.

## Exercises

Start the lab: `make up LAB=01`

### 1. Look around

```bash
make shell LAB=01 NODE=h1
ip -br addr          # brief list of interfaces and addresses
ip route             # the routing table
```

Which interface carries the lab address? What does the line
`192.168.1.0/24 dev eth1 proto kernel scope link` in the routing table mean?

### 2. Talk to a neighbour and watch ARP

On h1:

```bash
ip neigh             # ARP cache: probably empty for eth1
ping -c 3 192.168.1.20
ip neigh             # now h2's MAC address is there
```

### 3. Find the broken host

From h1, `ping -c 3 192.168.1.130` (h3). It fails. Open a shell on h3 and look
at its address with `ip -br addr`.

<details><summary>Hint</summary>

h3 has a `/25`. Which range is `192.168.1.130/25`? Is `192.168.1.10` inside it?
If h3 thinks h1 is *not* local, where does it send the reply? (Look at
`ip route` on h3.)
</details>

Fix it so h3 uses a `/24`, keeping the address `.130`:

```bash
ip addr del 192.168.1.130/25 dev eth1
ip addr add 192.168.1.130/24 dev eth1
```

Then ping h3 from h1 again.

### 4. Configure h4 yourself

Give h4 the address `192.168.1.40/24` on `eth1` and ping h1 from it.

### 5. Subnet math

Work these out on paper first, then check with `busybox ipcalc -nbm <address/prefix>`
inside any node. Write your answers into a new file `labs/01-ip-subnets/answers.txt`,
one per line, exactly in this format:

```
broadcast=<broadcast address of 192.168.1.130/25>
hosts26=<number of usable hosts in a /26>
network=<network address of 10.20.30.77/27>
```

<details><summary>Hint for the /27</summary>

A /27 block has 32 addresses, so networks start at multiples of 32 in the last
octet: 0, 32, 64, 96... Which block contains 77?
</details>

## Check your work

```bash
make check LAB=01
```

## Going further

- Put h4 at `192.168.1.40/28`. Which hosts can it still reach, and why?
- Add a second address to h1 and h2 in `10.0.0.0/24` (`ip addr add 10.0.0.1/24 dev eth1`).
  Two subnets can share one switch: what does that tell you about the difference
  between a switch and a router?
