module PiggybakBraintree
  module OrdersControllerDecorator
    extend ActiveSupport::Concern

    included do
      def submit
        super
        unless request.post?
          payment_method = ::PiggybakBraintree::PaymentCalculator::Braintree.new(@order.payment_method)
          payment_method.configure
          @client_token = payment_method.client_token
        end
      end
    end
  end
end
