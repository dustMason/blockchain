require 'net/http'
require 'set'
require 'json'
require_relative 'blockchain'
require_relative 'block'
require_relative 'ledger'
require_relative 'wallet'

class Node
  attr_reader :id, :blockchain, :peers, :ledger, :wallet
  
  def initialize
    @id = SecureRandom.uuid
    @peers = Set.new
    @wallet = Wallet.new
    @blockchain = Blockchain.new @wallet.address
    @ledger = Ledger.new @blockchain.chain
  end
  
  def add_peer address
    @peers.add address
  end
  
  def create_transaction from, to, amount, public_key, id=nil, signature='0'
    transaction = Transaction.new from, to, amount, public_key, (id || SecureRandom.uuid), signature
    add_transaction transaction
  end
  
  def send to, amount
    transaction = @wallet.generate_transaction to, amount
    add_transaction transaction
  end
  
  def mine!
    @blockchain.create_block!
    @ledger = Ledger.new @blockchain.chain
    send_chain_to_peers
  end
  
  def resolve chain_data
    if @blockchain.resolve! parse_chain(chain_data)
      @ledger = Ledger.new @blockchain.chain
      send_chain_to_peers
      return true
    else
      return false
    end
  end
  
  private
  
  def add_transaction trans
    if @ledger.sufficient_funds?(trans.from, trans.amount) && @blockchain.add_transaction(trans)
      @peers.each { |address| Net::HTTP.post_form(URI(address + "/transactions"), trans.to_h) }
      return true
    else
      return false
    end
  end
  
  def send_chain_to_peers
    @peers.each { |address| Net::HTTP.post(URI(address + "/resolve"), dump_chain.to_json) }
  end
  
  def dump_chain
    @blockchain.chain.map &:to_h
  end
  
  def parse_chain chain_data
    prev = nil
    chain_data.map do |block_data|
      block = Block.from_h block_data, prev
      prev = block
      block
    end
  end
end
