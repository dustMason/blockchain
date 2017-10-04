require_relative 'block'
require_relative 'transaction'

class Blockchain
  attr_reader :pending, :chain
  
  COINBASE = "COINBASE"
  MINING_REWARD_AMOUNT = 5
  
  def initialize address
    @chain = []
    @pending = []
    @address = address
    create_block! # genesis block
  end
  
  def create_block!
    add_transaction Transaction.new(COINBASE, @address, MINING_REWARD_AMOUNT, '0', SecureRandom.uuid)
    block = Block.new(index: @chain.size, time: Time.now, transactions: @pending, previous: @chain.last)
    @pending = []
    @chain << block.mine!
  end
  
  def add_transaction transaction
    if transaction_is_new?(transaction) && transaction.valid_signature?
      @pending << transaction
      return true
    else
      return false
    end
  end
  
  def resolve! chain=[]
    # TODO this does not protect against invalid block shapes (bogus COINBASE transactions for example)
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
  
  def transaction_is_new? transaction
    (transactions + @pending).none? { |trans| transaction.id == trans.id }
  end
  
  def transactions
    @chain.reduce([]) { |acc, block| acc + block.transactions }
  end
end
