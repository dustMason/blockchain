class Ledger
  getter :wallets
  
  def initialize(chain : Array(Block))
    @wallets = {} of String => UInt64
    chain.each { |block| apply_transactions block.transactions if block.valid? }
  end
  
  def sufficient_funds?(wallet : String, amount : UInt64)
    return true if wallet == Blockchain::COINBASE
    @wallets.has_key?(wallet) && @wallets[wallet] - amount >= 0
  end
  
  private def apply_transactions(transactions : Array(Transaction))
    transactions.each do |t|
      if sufficient_funds?(t.from, t.amount)
        @wallets[t.from] -= t.amount unless t.from == Blockchain::COINBASE
        @wallets[t.to] ||= 0_u64
        @wallets[t.to] += t.amount
      end
    end
  end
  
end
