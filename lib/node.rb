require 'net/http'
require 'set'
require 'json'
require_relative 'block'
require_relative 'blockchain'
require_relative 'ledger'
require_relative 'wallet'

class Node
  attr_reader :id, :blockchain, :peers, :ledger, :wallet
  
  def initialize
    @id = SecureRandom.uuid
    @peers = []
    @wallet = Wallet.new
    @blockchain = Blockchain.new @wallet.address
    @ledger = Ledger.new @blockchain.chain
  end
  
  def add_peer host, port
    @peers << [host, port]
    @peers.uniq!
    # TODO no need to send to every peer, just the new one
    send_chain_to_peers
    blockchain.pending.each { |trans| send_transaction_to_peers trans }
  end
  
  def remove_peer index
    @peers.delete_at index
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
    if @blockchain.resolve! chain_data
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
      send_transaction_to_peers trans
      return true
    else
      return false
    end
  end
  
  def send_chain_to_peers
    @peers.each do |(host, port)|
      Net::HTTP.post(URI::HTTP.build(host: host, port: port, path: '/resolve'), @blockchain.to_json)
    end
  end
  
  def send_transaction_to_peers trans
    @peers.each do |(host, port)|
      Net::HTTP.post_form(URI::HTTP.build(host: host, port: port, path: '/transactions'), trans.to_h)
    end
  end
end
