# Lab 05: DHCP and DNS

```
  srv 10.5.0.2        web 10.5.0.80      h1 (no address)    h2 (no address)
  (dnsmasq)               |                  |                  |
      |                   |                  |                  |
  +------------------------------ sw ---------------------------------+
                      10.5.0.0/24, domain lab.local
```

h1 and h2 boot with no IP address. srv runs **dnsmasq**, a small server that
does both DHCP (hands out addresses) and DNS (turns names into addresses). Its
config lives in this folder, in [`srv/`](srv/), so you can edit it from your editor.

## Goals

- Get an address over DHCP and see the four-step DHCP exchange (DORA)
- Reserve a fixed address for a specific client
- Query DNS with `dig`, including reverse lookups
- Add your own DNS records

## Concepts in two minutes

**DHCP** lets a host with no address ask for one. It happens in four
broadcast/reply steps, **DORA**:

1. **D**iscover: client broadcasts "is there a DHCP server?"
2. **O**ffer: server replies "you can have 10.5.0.1xx"
3. **R**equest: client says "I'll take it"
4. **A**ck: server confirms, along with extras like the DNS server and domain

**DNS** maps names to addresses. An **A record** maps `web.lab.local` to
`10.5.0.80`; a **PTR record** goes the other way, for reverse lookups. On a
Linux host, `/etc/resolv.conf` says which DNS server to ask.

## Exercises

Start the lab: `make up LAB=05`

Keep the server log open in a second terminal for the whole lab:

```bash
docker exec clab-lab05-srv tail -f /var/log/dnsmasq.log
```

### 1. Watch DORA

Start a capture on the switch, on h1's port, then request an address from h1
in another terminal:

```bash
make shell LAB=05 NODE=sw
tcpdump -i eth3 -n -v port 67 or port 68
```

```bash
make shell LAB=05 NODE=h1
udhcpc -i eth1 -n -q
ip -br addr show eth1
```

Find the four DORA messages in the capture (look for `DHCP-Message ... Discover`,
`Offer`, `Request`, `ACK`). Which ones are broadcasts (to `255.255.255.255`)? Why
must the first ones be? (udhcpc will also complain that it can't replace
`/etc/resolv.conf`; that's expected, and you'll fix it in exercise 3.)

### 2. Ask the DNS server directly

From h1:

```bash
dig @10.5.0.2 web.lab.local
dig @10.5.0.2 -x 10.5.0.80        # reverse lookup
dig @10.5.0.2 nothing.lab.local   # what status comes back?
```

Look at the `ANSWER SECTION` and the `status:` line.

### 3. Use the DNS server by default

The DHCP Ack told h1 to use 10.5.0.2 for DNS, but Docker controls h1's
`/etc/resolv.conf`, so udhcpc couldn't write it. Do it by hand on h1:

```bash
printf "nameserver 10.5.0.2\nsearch lab.local\n" > /etc/resolv.conf
ping -c 2 web          # short name works thanks to "search lab.local"
```

### 4. Reserve an address for h2

Edit [`srv/dnsmasq.conf`](srv/dnsmasq.conf) and add a `dhcp-host` line so the
client named `h2` always gets `10.5.0.42`. Reload dnsmasq:

```bash
bash labs/05-dns-dhcp/reload-dns.sh
```

Then on h2, send its hostname with the request: `udhcpc -i eth1 -n -q -x hostname:h2`.

<details><summary>Hint</summary>

The syntax is `dhcp-host=<name or MAC>,<address>`. Search for `dhcp-host` in
`man dnsmasq` or online.
</details>

### 5. Add a record

Add `db.lab.local` → `10.5.0.53` to [`srv/lab.hosts`](srv/lab.hosts), reload,
and resolve it from h1. Does the reverse lookup for `10.5.0.53` work too?

## Check your work

```bash
make check LAB=05
```

## Going further

- Run `udhcpc` on h1 again. Does it get the same address? Look at
  `/var/lib/misc/dnsmasq.leases` on srv.
- Add a **CNAME** (alias) so `www.lab.local` points to `web.lab.local`
  (`cname=www.lab.local,web.lab.local` in dnsmasq.conf).
- Capture DNS with `tcpdump -i eth3 -n port 53` on sw while you `dig` from h1. Is DNS
  using TCP or UDP?
