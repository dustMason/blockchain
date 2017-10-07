# Blockchain Toy

Inspired by @dvf's blog post [Learn Blockchains by Building One](https://hackernoon.com/learn-blockchains-by-building-one-117428612f46), I decided to implement my own in ruby.

![dashboard](/dashboard.png?raw=true "Dashboard")

## Features

- [x] Blockchain: the integrity of each block depends on that of the previous one. Uses SHA256.
- [x] Proof of Work: a block is mined by finding a nonce that results in a hash with 4 leading zeros.
- [x] Consensus: the longest blockchain wins.
- [x] Secure Transactions: they are signed using ECDSA with a private key held by the initiator, and verified by each node before they get added to the blockchain.
- [x] Wallets: addresses are derived from a SHA256 hash of the public key belonging to the wallet.
- [x] Peering: each node manually names peers. They communicate via a JSON API over HTTP.
- [x] UI: each node runs a web based dashboard.
- [x] Persistence: each node keeps a local cache of the full blockchain (`blockchain.json`) and it's wallet keys (`wallet.json`)

## To Do

- [ ] Bootstrapping. https://en.bitcoin.it/wiki/Network#Bootstrapping
- [ ] Merkle Tree. Right now the entire blockchain is held in memory as a linked list.
- [ ] Peer heartbeat. https://en.bitcoin.it/wiki/Network#Heartbeat
- [ ] Partial blockchain download. When joining the network, a node should request the chain by providing the hash of the most recent block it has.

## Run It

```
# requires ruby 2.4+
bundle install
PASSWORD=cucumber PORT=4567 ruby app.rb
```

Load the web UI at http://localhost:4567. Username is *admin*, password as above.
