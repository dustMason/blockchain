require_relative 'block'
require_relative 'ledger'

Transaction = Struct.new(:from, :to, :amount)

class Blockchain
  attr_reader :pending, :chain, :ledger
  
  MINING_REWARD = "MINING REWARD"
  MINING_REWARD_AMOUNT = 5
  
  def initialize
    @chain = []
    @pending = []
    @node_identifier = SecureRandom.uuid.split("-").first
    @ledger = Ledger.new
    create_block! # genesis block
  end
  
  def create_block!
    create_transaction! MINING_REWARD, @node_identifier, MINING_REWARD_AMOUNT
    block = Block.new(index: @chain.size, time: Time.now, data: @pending, previous: @chain.last)
    @pending = []
    @chain << block.mine!
    @ledger.apply_transactions block.data
  end
  
  def create_transaction! from, to, amount
    @pending << Transaction.new(from, to, amount)
  end
  
  def valid?
    # Block#valid? recursively checks all linked blocks, so calling it on the last
    # block verifies every block in the chain.
    @chain.last.valid? 
  end
end
