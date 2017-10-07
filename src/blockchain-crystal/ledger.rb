require_relative 'blockchain'

class Ledger
  attr_reader :wallets
  
  def initialize chain=[]
    @wallets = {}
    chain.each { |block| apply_transactions block.transactions if block.valid? }
  end
  
  def sufficient_funds? wallet, amount
    return true if wallet == Blockchain::COINBASE
    @wallets.has_key?(wallet) && @wallets[wallet] - amount >= 0
  end
  
  private
  
  def apply_transactions transactions
    transactions.each do |t|
      if sufficient_funds?(t.from, t.amount)
        @wallets[t.from] -= t.amount unless t.from == Blockchain::COINBASE
        @wallets[t.to] ||= 0
        @wallets[t.to] += t.amount
      end
    end
  end
  
end
