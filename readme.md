# Blockchain Toy

Inspired by @dvf's blog post [Learn Blockchains by Building One](https://hackernoon.com/learn-blockchains-by-building-one-117428612f46), I decided to implement my own in ruby. I came up with a few ways to improve upon @dvf's example and learned a lot in the process. I'm now very curious to dive into the Bitcoin source and learn more about how some of these problems are solved.

To run the 'app', simply `bundle install` and `ruby app.rb`. You can interact with a simple web interface at http://localhost:4567.

- A genesis block is mined when the blockchain is initialized and the reward is assigned to a new random address. You can send funds from that address to new ones.

- The ledger ignores invalid transactions, but they are still allowed into the blocks.

- The blockchain itself is stored as a singly linked list. The hash of each block is computed from a combination of its own data and the hash of the previous linked block.

- Like Bitcoin, SHA256 is the hashing algorithm used. The proof of work algorithm is super simple, though, and simply looks for a nonce resulting in a hash with 4 leading zeros.
