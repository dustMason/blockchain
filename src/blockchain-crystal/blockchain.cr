class Blockchain
  getter :pending, :chain
  
  COINBASE = "COINBASE"
  MINING_REWARD_AMOUNT = 5_u64
    
  @chain = [] of Block
  @pending = [] of Transaction
  
  def initialize(@mining_wallet : String)
    # @cache = JsonCache.new 'blockchain.json'
    # unless load_from_cache
    #   create_block! # genesis block
    # end
    create_block!
  end
  
  def create_block!
    add_transaction Transaction.new(
      from: COINBASE,
      to: @mining_wallet,
      amount: MINING_REWARD_AMOUNT,
      public_key: "0",
      id: SecureRandom.uuid,
      signature: ""
    )
    block = Block.new(
      index: @chain.size.to_u64,
      time: Time.now,
      transactions: @pending,
      previous: @chain.any? ? @chain.last : nil,
      nonce: 0_u64
    )
    @pending = [] of Transaction
    @chain << block.mine!
    # @cache.write to_json
  end
  
  def add_transaction(transaction : Transaction)
    if transaction_is_new?(transaction) && transaction.valid_signature?
      @pending << transaction
      # @cache.write to_json
      return true
    else
      return false
    end
  end
  
  def resolve!(chain_data : String)
    chain = parse_chain chain_data
    # TODO this does not protect against invalid block shapes (bogus COINBASE transactions for example)
    if !chain.empty? && chain.last.valid? && chain.size > @chain.size
      @chain = chain
      _transactions = transactions
      @pending = @pending.select { |trans| _transactions.none? { |t| t.id == trans.id } }
      # @cache.write to_json
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
  
  # private def load_from_cache
  #   data = @cache.read
  #   if data
  #     resolve! data['chain']
  #     transactions = data['transactions'].map { |hash| Transaction.from_h hash }
  #     transactions.each { |trans| add_transaction trans }
  #   end
  # end
  
  private def parse_chain(chain_data : String)
    prev = nil
    chain_data.map do |block_data|
      block = Block.from_h block_data, prev
      prev = block
      block
    end
  end
  
  private def transaction_is_new?(transaction : Transaction)
    (transactions + @pending).none? { |trans| transaction.id == trans.id }
  end
  
  private def transactions
    @chain.reduce([] of Transaction) { |acc, block| acc + block.transactions }
  end
end
