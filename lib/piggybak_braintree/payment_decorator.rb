module PiggybakBraintree
  module PaymentDecorator
    extend ActiveSupport::Concern

    included do
      attr_accessor :payment_method_nonce

      validates_presence_of :payment_method_nonce, :on => :create
      
      def process(order)
        return true unless self.new_record?

        ::PiggybakBraintree::PaymentCalculator::Braintree.new(self.payment_method).configure

        result = Braintree::Transaction.sale(
            :amount => (order.total_due * 100).to_i,
            :payment_method_nonce => self.payment_method_nonce
        )
      end
    end
  end
end
