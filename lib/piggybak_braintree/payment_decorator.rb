module PiggybakBraintree
  module PaymentDecorator
    extend ActiveSupport::Concern

    included do
      attr_accessor :payment_method_nonce

      validates_presence_of :payment_method_nonce, :on => :create

      def credit_card
        self.payment_method_nonce
      end

      def process(order)
        return true if !self.new_record?

        calculator = ::PiggybakBraintree::PaymentCalculator::Braintree.new(self.payment_method)
        Braintree::Configuration.environment = calculator.gateway_mode
        Braintree::Configuration.merchant_id = calculator.merchant_id
        Braintree::Configuration.public_key  = calculator.public_key
        Braintree::Configuration.private_key = calculator.private_key

        raise
        result = Braintree::Transaction.sale(
            :amount => (order.total_due * 100).to_i,
            :payment_method_nonce => self.credit_card
        )
      end
    end
  end
end
