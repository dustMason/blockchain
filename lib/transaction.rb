require 'digest'
require 'base64'
require 'openssl'

Transaction = Struct.new(:from, :to, :amount, :public_key, :id, :signature) do
  def hash
    # we don't really need this yet, but we will once we implement bitcoin-style
    # transactions where each one spends the entire amount every time.
    Digest::SHA256.hexdigest self.to_h.to_s
  end
  
  def self.from_h hash
    self.new *hash.values_at('from', 'to', 'amount', 'public_key', 'id', 'signature')
  end
  
  def valid_signature?
    return true if from == Blockchain::COINBASE
    return false if from != Digest::SHA256.hexdigest(public_key)
    group = OpenSSL::PKey::EC::Group.new 'secp256k1'
    key = OpenSSL::PKey::EC.new group
    public_key_bn = OpenSSL::BN.new public_key, 16
    public_key = OpenSSL::PKey::EC::Point.new group, public_key_bn
    key.public_key = public_key
    sig = Base64.strict_decode64 self.signature
    key.dsa_verify_asn1 signable_string, sig
  end
  
  def signable_string
    self.to_h.reject { |k, _| k == :signature }.to_s
  end
end
