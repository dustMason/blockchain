require_relative 'block'
require_relative 'json_cache'
require_relative 'transaction'

class Blockchain
  attr_reader :pending, :chain
  
  COINBASE = "COINBASE"
  MINING_REWARD_AMOUNT = 5
  
  def initialize address
    @chain = []
    @pending = []
    @address = address
    @cache = JsonCache.new 'blockchain.json'
    unless load_from_cache
      create_block! # genesis block
    end
  end
  
  def create_block!
    add_transaction Transaction.new(COINBASE, @address, MINING_REWARD_AMOUNT, '0', SecureRandom.uuid)
    block = Block.new(index: @chain.size, time: Time.now, transactions: @pending, previous: @chain.last)
    @pending = []
    @chain << block.mine!
    @cache.write to_json
  end
  
  def add_transaction transaction
    if transaction_is_new?(transaction) && transaction.valid_signature?
      @pending << transaction
      @cache.write to_json
      return true
    else
      return false
    end
  end
  
  def resolve! chain_data
    chain = parse_chain chain_data
    # TODO this does not protect against invalid block shapes (bogus COINBASE transactions for example)
    if !chain.empty? && chain.last.valid? && chain.size > @chain.size
      @chain = chain
      _transactions = transactions
      @pending = @pending.select { |trans| _transactions.none? { |t| t.id == trans.id } }
      @cache.write to_json
      return true
    else
      return false
    end
  end
  
  def to_json
    { chain: @chain.map(&:to_h), transactions: @pending.map(&:to_h) }.to_json
  end
  
  def size
    @chain.size
  end
  
  private
  
  def load_from_cache
    data = @cache.read
    if data
      resolve! data['chain']
      transactions = data['transactions'].map { |hash| Transaction.from_h hash }
      transactions.each { |trans| add_transaction trans }
    end
  end
  
  def parse_chain chain_data
    prev = nil
    chain_data.map do |block_data|
      block = Block.from_h block_data, prev
      prev = block
      block
    end
  end
  
  def transaction_is_new? transaction
    (transactions + @pending).none? { |trans| transaction.id == trans.id }
  end
  
  def transactions
    @chain.reduce([]) { |acc, block| acc + block.transactions }
  end
end
