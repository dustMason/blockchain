require 'digest'
require 'openssl'
require 'base64'
require_relative 'json_cache'
require_relative 'transaction'

class Wallet
  attr_reader :address
  
  def initialize
    @cache = JsonCache.new 'wallet.json'
    unless load_from_cache
      @private_key = OpenSSL::PKey::EC.new 'secp256k1'
      @private_key.generate_key
    end
    @public_key = @private_key.public_key
    @address = Digest::SHA256.hexdigest public_key
    @cache.write to_json
  end
  
  def public_key
    @public_key.to_bn.to_s(16).downcase
  end
  
  def generate_transaction to, amount
    transaction = Transaction.new address, to, amount, public_key, SecureRandom.uuid
    transaction.signature = signature(transaction)
    transaction
  end
  
  def to_json
    { private_key: @private_key.to_pem, public_key: public_key }.to_json
  end
  
  private
  
  def signature transaction
    Base64.strict_encode64 @private_key.dsa_sign_asn1(transaction.signable_string)
  end
  
  def load_from_cache
    data = @cache.read
    if data
      @private_key = OpenSSL::PKey::EC.new data['private_key']
    end
  end
end
