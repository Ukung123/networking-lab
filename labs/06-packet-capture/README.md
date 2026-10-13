# Lab 06: Packet capture

```
  h1 10.6.1.10 ---eth1 r1 eth2--- srv 10.6.2.80
        10.6.1.0/24         10.6.2.0/24     (web server on port 80)
```

Everything in the earlier labs happened in packets you couldn't see. Here you
capture them. h1, srv and every lab switch have `tcpdump` and `tshark`
(Wireshark's command-line twin). h1 and srv share this lab's
[`captures/`](captures/) folder at `/captures`, so a file you save there shows
up in the repo, ready to open in Wireshark.

This lab is also your first step into security: you'll pull a "secret" out of
someone else's web traffic.

## Goals

- Capture live traffic with `tcpdump` and save it to a `.pcap` file
- Read captures with `tshark` and Wireshark display filters
- See ARP, ICMP TTL, the TCP three-way handshake and an HTTP request
- Understand why unencrypted protocols are dangerous

## Cheat sheet

```bash
tcpdump -i eth1 -n                    # live, don't resolve names
tcpdump -i eth1 -n -e arp             # only ARP, show MAC addresses
tcpdump -i eth1 -n -w /captures/x.pcap   # save to a file (Ctrl+C to stop)
tshark -r /captures/x.pcap            # read a file, one line per packet
tshark -r /captures/x.pcap -Y 'tcp.flags.syn == 1'   # Wireshark display filter
tshark -r /captures/x.pcap -V -c 1    # every field of the first packet
```

Capture filters (tcpdump, `arp`, `port 80`) decide what gets **recorded**.
Display filters (tshark `-Y`, Wireshark's filter bar) decide what gets
**shown** from a recording.

## Exercises

Start the lab: `make up LAB=06`. You'll want two terminals for most steps.

### 1. ARP: finding a MAC address

On h1, forget the gateway's MAC, start capturing, then ping it:

```bash
ip neigh flush dev eth1
tcpdump -i eth1 -n -e arp -w /captures/arp.pcap
```

In a second h1 shell: `ping -c 1 10.6.1.1`. Stop the capture with Ctrl+C and
read it with `tshark -r /captures/arp.pcap`. Who asks, who answers, and which
one is a broadcast (destination `ff:ff:ff:ff:ff:ff`)?

### 2. TTL: counting routers

On **srv**, capture ICMP into `/captures/ttl.pcap`, and from h1
`ping -c 2 10.6.2.80`. Then read the TTL of the echo requests:

```bash
tshark -r /captures/ttl.pcap -Y 'icmp.type == 8' -T fields -e ip.src -e ip.ttl
```

Linux sends with TTL 64. What value does srv see, and what changed it? (This
is exactly how `traceroute` works: try it from h1 while capturing.)

### 3. TCP handshake and HTTP

On srv, capture port 80 into `/captures/http.pcap`. From h1 fetch the page:
`curl http://10.6.2.80/`. Stop the capture and find:

- the three-way handshake: SYN, SYN/ACK, ACK (`-Y 'tcp.flags.syn == 1'`)
- the HTTP request (`-Y http.request`)
- the connection teardown (`-Y 'tcp.flags.fin == 1'`)

### 4. Read someone else's traffic

Pretend you only have `http.pcap`, not the curl output. Rebuild the
conversation from the capture alone:

```bash
tshark -r /captures/http.pcap -q -z follow,tcp,ascii,0
```

The page hides a line starting with `flag=`. Write it into a new file
`labs/06-packet-capture/answers.txt` as a single line, for example `flag=...`.

Anyone between h1 and srv (r1, a switch, a Wi-Fi access point) can do the same.
That's why the web moved to HTTPS.

### 5. Open your captures in Wireshark

Install [Wireshark](https://www.wireshark.org/) on your own computer. In
Codespaces, right-click a file in `labs/06-packet-capture/captures/` →
**Download**, then open it. Try **Statistics → Conversations** and
**Analyze → Follow → TCP Stream** on `http.pcap`.

## Check your work

```bash
make check LAB=06
```

## Going further

- Capturing on a router: r1 has no tcpdump, but you can borrow the host's.
  Containerlab registers every node's network namespace, so on the Codespace
  run `sudo apt-get install -y tcpdump` once, then
  `sudo ip netns exec clab-lab06-r1 tcpdump -i eth1 -n`.
- Go back to Lab 04, capture on a router link and find the OSPF Hello packets
  (`ospf` filter). What's in them?
