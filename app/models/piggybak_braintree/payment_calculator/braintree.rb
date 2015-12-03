module PiggybakBraintree
  class PaymentCalculator::Braintree
    KEYS = ['private_key', 'public_key', 'merchant_id']
    KLASS = ::Braintree

    def initialize(payment_method = nil)
      @payment_method = payment_method || ::Piggybak::PaymentMethod.find_by(klass: '::PiggybakBraintree::PaymentCalculator::Braintree')
    end

    def configure
      Braintree::Configuration.environment = gateway_mode
      Braintree::Configuration.merchant_id = merchant_id
      Braintree::Configuration.public_key = public_key
      Braintree::Configuration.private_key = private_key
    end

    def client_token(user)
      customer_id =
          if user.customer_id
            user.customer_id
          else
            results = Braintree::Customer.create(
                :email => user.email
            )
            user.update_column(:customer_id, results.customer.id)
            user.customer_id
          end
      Braintree::ClientToken.generate(:customer_id => customer_id)
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

