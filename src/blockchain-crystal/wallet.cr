class Wallet
  getter :address
  
  def initialize
    # @cache = Cache.new 'wallet.json'
    # unless load_from_cache
    #   @private_key = OpenSSL::PKey::EC.new 'secp256k1'
    #   @private_key.generate_key
    # end
    # @public_key = @private_key.public_key
    # @address = Digest::SHA256.hexdigest public_key
    @address = "address"
    # @cache.write to_json
  end
  
  def public_key
    # @public_key.to_bn.to_s(16).downcase
    "public_key"
  end

  def generate_transaction(to : String, amount : UInt64)
    transaction = Transaction.new address, to, amount, public_key, SecureRandom.uuid, ""
    transaction.signature = signature(transaction)
    transaction
  end

  def to_json
    { private_key: @private_key.to_pem, public_key: public_key }.to_json
  end
  
  private def signature(transaction : Transaction)
    # Base64.strict_encode @private_key.dsa_sign_asn1(transaction.signable_string)
    Base64.strict_encode "transaction"
  end

  def load_from_cache
    # data = @cache.read
    # if data
    #   @private_key = OpenSSL::PKey::EC.new data['private_key']
    # end
    false
  end
end
