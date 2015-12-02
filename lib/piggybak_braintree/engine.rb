require 'piggybak_braintree/payment_decorator'
require 'piggybak_braintree/orders_controller_decorator'

module PiggybakBraintree
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakBraintree
    require 'braintree'

    config.to_prepare do
      Piggybak::Payment.send(:include, ::PiggybakBraintree::PaymentDecorator)
      Piggybak::OrdersController.send(:include, ::PiggybakBraintree::OrdersControllerDecorator)
    end

    initializer "piggybak_realtime_shipping.add_calculators" do
      Piggybak.config do |config|
        #Ensures that stripe is the only calculator because Piggybak
        #only supports one active calculator
        config.payment_calculators = ["::PiggybakBraintree::PaymentCalculator::Braintree"]
        # Override the default country
        config.default_country = "LV"
        # Override the activemerchant billing mode
        config.activemerchant_mode = :sandbox
        config.additional_line_item_attributes = [:payment_method_nonce]
      end
    end
  end
end
