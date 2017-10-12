require "digest"

class Block
  property :transactions
  getter :index, :time, :nonce
  
  def initialize(
    @index : UInt64,
    @time : Time,
    @transactions : Array(Transaction),
    @previous : (Block | Nil),
    @nonce : UInt64
  ); end
  
  def hash
    Digest::SHA1.hexdigest "#{index}#{time}#{transactions}#{previous_hash}"
  end
  
  def verification
    Digest::SHA1.hexdigest "#{hash}#{nonce}"
  end
  
  def mine!
    @nonce = find_nonce
    self
  end
  
  def valid?
    # TODO enforce the COINBASE transaction rule also
    # ie, there can only be one COINBASE transaction, and for the correct amount
    valid_proof? nonce
  end
  
  def previous_hash
    @previous.nil? ? "genesis" : @previous.hash
  end
  
  def to_h
    { index: index, time: time, transactions: transactions.map(&:to_h), nonce: nonce, hash: hash }
  end
  
  def self.from_h(h : Hash(String | (String | Array(Hash(String | String)))), previous : Block)
    transactions = h["transactions"].map { |hash| Transaction.from_h hash }
    self.new index: h["index"], time: h["time"], transactions: transactions, previous: previous, nonce: h["nonce"]
  end
  
  def valid_proof?(_nonce : UInt64)
    Digest::SHA1.hexdigest("#{hash}#{_nonce}")[0..3] == "0000"
  end
  
  def find_nonce
    _nonce = 0_u64
    until valid_proof?(_nonce)
      _nonce += 1
    end
    _nonce
  end
  
end
