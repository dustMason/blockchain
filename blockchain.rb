require_relative 'block'
require_relative 'transaction'

class Blockchain
  attr_reader :pending, :chain, :id
  
  COINBASE = "COINBASE"
  MINING_REWARD_AMOUNT = 5
  
  def initialize id
    @chain = []
    @pending = []
    @id = id
    create_block! # genesis block
  end
  
  def create_block!
    add_transaction Transaction.new(COINBASE, @id, MINING_REWARD_AMOUNT, SecureRandom.uuid)
    block = Block.new(index: @chain.size, time: Time.now, transactions: @pending, previous: @chain.last)
    @pending = []
    @chain << block.mine!
  end
  
  def add_transaction transaction
    if (transactions + @pending).none? { |trans| transaction.id == trans.id }
      @pending << transaction
      return true
    else
      return false
    end
  end
  
  def resolve! chain=[]
    if !chain.empty? && chain.last.valid? && chain.size > @chain.size
      @chain = chain
      _transactions = transactions
      @pending = @pending.select { |trans| _transactions.none? { |t| t.id == trans.id } }
      return true
    else
      return false
    end
  end
  
  private
  
  def transactions
    @chain.reduce([]) { |acc, block| acc + block.transactions }
  end
end
