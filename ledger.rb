require_relative 'blockchain'

class Ledger
  attr_reader :wallets
  
  def initialize
    @wallets = {}
  end
  
  def apply_transactions transactions
    transactions.each do |t|
      if t.from == Blockchain::MINING_REWARD || sufficient_funds?(t.from, t.amount)
        @wallets[t.from] -= t.amount unless t.from == Blockchain::MINING_REWARD
        @wallets[t.to] ||= 0
        @wallets[t.to] += t.amount
      end
    end
  end
  
  def sufficient_funds? wallet, amount
    @wallets.has_key?(wallet) && @wallets[wallet] - amount >= 0
  end
end
