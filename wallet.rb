require 'digest'
require 'openssl'
require 'base64'
require_relative 'transaction'

class Wallet
  attr_reader :address, :public_key
  
  def initialize
    @private_key = OpenSSL::PKey::EC.new 'secp256k1'
    @private_key.generate_key
    @public_key = @private_key.public_key
    @address = Digest::SHA256.hexdigest public_key
  end
  
  def public_key
    @public_key.to_bn.to_s(16).downcase
  end
  
  def generate_transaction to, amount
    transaction = Transaction.new address, to, amount, public_key, SecureRandom.uuid
    transaction.signature = signature(transaction)
    transaction
  end
  
  private
  
  def signature transaction
    Base64.strict_encode64 @private_key.dsa_sign_asn1(transaction.signable_string)
  end
end
