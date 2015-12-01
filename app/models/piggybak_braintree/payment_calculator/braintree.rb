module PiggybakBraintree
  class PaymentCalculator::Braintree
    KEYS = ['private_key', 'public_key', 'merchant_id']
    KLASS = ::Braintree

    def initialize(payment_method)
      @payment_method = payment_method
    end

    def configure
      Braintree::Configuration.environment = gateway_mode
      Braintree::Configuration.merchant_id = merchant_id
      Braintree::Configuration.public_key = public_key
      Braintree::Configuration.private_key = private_key
    end

    def client_token
      Braintree::ClientToken.generate
    end

    def gateway_mode
      Piggybak.config.activemerchant_mode
    end

    def private_key
      @payment_method.key_values["private_key".to_sym]
    end

    def public_key
      @payment_method.key_values["public_key".to_sym]
    end

    def merchant_id
      @payment_method.key_values["merchant_id".to_sym]
    end

  end
end

