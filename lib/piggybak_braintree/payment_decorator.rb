module PiggybakBraintree
  module PaymentDecorator
    extend ActiveSupport::Concern

    included do
      attr_accessor :payment_method_nonce

      validates :payment_method_nonce, presence: true
      validates :month, presence: true, unless: :payment_method_nonce
      validates :year, presence: true, unless: :payment_method_nonce

      def process(order)
        return true unless self.new_record?

        ::PiggybakBraintree::PaymentCalculator::Braintree.new(self.payment_method).configure

        result = Braintree::Transaction.sale(
            :amount => (order.total_due * 100).to_i,
            :payment_method_nonce => self.payment_method_nonce
        )
        if result.success?
          self.attributes = {
              transaction_id: 123,
              masked_number: self.number.mask_cc_number
          }
        else
          self.errors.add :payment_method_id, result.message
          return false
        end
      end
    end
  end
end
