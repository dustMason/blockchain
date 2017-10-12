struct Transaction
  property from : String
  property to : String
  property amount : UInt64
  property public_key : String
  property id : String
  property signature : String
  
  def initialize(
    @from : String,
    @to : String,
    @amount : UInt64,
    @public_key : String,
    @id : String,
    @signature : String
  ); end
  
  def self.from_h(hash : Hash(String | String))
    self.new *hash.values_at("from", "to", "amount", "public_key", "id", "signature")
  end
  
  def hash
    Digest::SHA1.hexdigest self.to_h.to_s
  end
  
  def valid_signature?
    true
    # return true if from == Blockchain::COINBASE
    # return false if from != Digest::SHA256.hexdigest(public_key)
    # group = OpenSSL::PKey::EC::Group.new 'secp256k1'
    # key = OpenSSL::PKey::EC.new group
    # public_key_bn = OpenSSL::BN.new public_key, 16
    # public_key = OpenSSL::PKey::EC::Point.new group, public_key_bn
    # key.public_key = public_key
    # sig = Base64.strict_decode64 self.signature
    # key.dsa_verify_asn1 signable_string, sig
  end
  
  def signable_string
    self.to_h.reject { |k, _| k == :signature }.to_s
  end
  
  def to_h
    {
      from: @from,
      to: @to,
      amount: @amount,
      public_key: @public_key,
      id: @id,
      signature: @signature
    }
  end
end
