require 'piggybak_braintree/payment_decorator'
require 'piggybak_braintree/order_decorator'
require 'piggybak_braintree/orders_controller_decorator'

module PiggybakBraintree
  class Engine < ::Rails::Engine
    isolate_namespace PiggybakBraintree
    require 'braintree'

    config.to_prepare do
      Piggybak::Payment.send(:include, ::PiggybakBraintree::PaymentDecorator)
      Piggybak::Order.send(:include, ::PiggybakBraintree::OrderDecorator)
      Piggybak::OrdersController.send(:include, ::PiggybakBraintree::OrdersControllerDecorator)
    end

    config.model Piggybak::Sellable do
      label "Sellable"
      visible false
      edit do
        field :sku
        field :description
        field :price
        field :active
        field :quantity
        field :days
        field :unlimited_inventory do
          help "If true, backorders on this variant will be allowed, regardless of quantity on hand."
        end
      end
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
      end
    end
  end
end
