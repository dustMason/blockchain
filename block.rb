require 'digest'

class Block
  attr_accessor :transactions
  attr_reader :index, :time, :nonce
  
  def initialize index:, time:, transactions:, previous:, nonce: nil
    @index = index
    @time = time
    @transactions = transactions
    @nonce = nonce
    @previous = previous
  end
  
  def hash
    Digest::SHA256.hexdigest "#{index}#{time}#{transactions}#{previous_hash}"
  end
  
  def verification
    Digest::SHA256.hexdigest "#{hash}#{nonce}"
  end
  
  def mine!
    @nonce = find_nonce
    self
  end
  
  def valid?
    valid_proof? nonce
  end
  
  def previous_hash
    @previous.nil? ? 'genesis' : @previous.hash
  end
  
  def to_h
    { index: index, time: time, transactions: transactions.map(&:to_h), nonce: nonce, hash: hash }
  end
  
  def self.from_h h, previous=nil
    transactions = h['transactions'].map { |t| Transaction.new t['from'], t['to'], t['amount'], t['id'] }
    self.new index: h['index'], time: h['time'], transactions: transactions, previous: previous, nonce: h['nonce']
  end
  
  private
  
  def find_nonce
    _nonce = 0
    _nonce += 1 until valid_proof? _nonce
    _nonce
  end
  
  def valid_proof? _nonce
    Digest::SHA256.hexdigest("#{hash}#{_nonce}")[0..3] == "0000"
  end
end
