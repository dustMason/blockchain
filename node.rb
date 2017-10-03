require 'net/http'
require 'set'
require 'json'
require_relative 'blockchain'
require_relative 'block'
require_relative 'ledger'

class Node
  attr_reader :id, :blockchain, :peers, :ledger
  
  def initialize
    @id = SecureRandom.uuid
    @peers = Set.new
    @blockchain = Blockchain.new @id
    @ledger = Ledger.new @blockchain.chain
  end
  
  def add_peer address
    @peers.add address
  end
  
  def add_transaction from, to, amount, id=nil
    transaction = Transaction.new from, to, amount, (id || SecureRandom.uuid)
    if @ledger.sufficient_funds?(from, amount) && @blockchain.add_transaction(transaction)
      @peers.each { |address| Net::HTTP.post_form(URI(address + "/transactions"), transaction.to_h) }
    end
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
