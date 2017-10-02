require_relative 'block'
require_relative 'ledger'

Transaction = Struct.new(:from, :to, :amount, :id)

class Blockchain
  attr_reader :pending, :chain, :ledger, :id
  
  MINING_REWARD = "MINED"
  MINING_REWARD_AMOUNT = 5
  
  def initialize
    @chain = []
    @pending = []
    @id = SecureRandom.uuid.split("-").first
    @ledger = Ledger.new
    create_block! # genesis block
  end
  
  def create_block!
    add_transaction Transaction.new(MINING_REWARD, @id, MINING_REWARD_AMOUNT, SecureRandom.uuid)
    valids = valid_pending_transactions
    invalids = @pending - valids
    block = Block.new(index: @chain.size, time: Time.now, transactions: valids, previous: @chain.last)
    @pending = invalids
    @chain << block.mine!
    @ledger = Ledger.new @chain
  end
  
  def add_transaction transaction
    if (transactions + @pending).none? { |trans| transaction.id == trans.id }
      @pending << transaction
    end
  end
  
  def valid?
    # Block#valid? recursively checks all linked blocks, so calling it on the last
    # block verifies every block in the chain.
    @chain.last.valid? 
  end
  
  def resolve! blockchain=nil
    if blockchain && blockchain.valid? && blockchain.size > size
      @chain = blockchain.chain.clone
      _transactions = transactions
      @pending = @pending.select { |trans| _transactions.none? { |t| t.id == trans.id } }
    end
    @ledger = Ledger.new @chain
  end
  
  def size
    @chain.size
  end
  
  private
  
  def valid_pending_transactions
    @pending.select { |trans| @ledger.sufficient_funds? trans.from, trans.amount }
  end
  
  def transactions
    @chain.reduce([]) { |acc, block| acc + block.transactions }
  end
end
