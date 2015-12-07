module PiggybakBraintree
  module PaymentDecorator
    extend ActiveSupport::Concern

    included do
      attr_accessor :payment_method_nonce

      validates :payment_method_nonce, presence: true

      [:month, :year, :number, :verification_value, :payment_method_id].each do |field|
        _validators.reject!{ |key, _| key == field }
        _validate_callbacks.each do |callback|
          callback.raw_filter.attributes.delete field if callback.filter.attributes.include?(field)
        end
      end

      def process(order)
        return true unless self.new_record?

        ::PiggybakBraintree::PaymentCalculator::Braintree.new(self.payment_method).configure

        result = Braintree::Transaction.sale(
            :amount => (order.total_due * 100).to_i,
            :payment_method_nonce => self.payment_method_nonce
        )
        puts result.inspect
        if result.success?
          self.attributes = {
              transaction_id: 123,
          }
        else
          self.errors.add :payment_method_id, result.errors
          return false
        end
      end
    end
  end
end
