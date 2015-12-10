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

    initializer "piggybak.rails_admin_config" do |config|
      RailsAdmin.config do |config|
        config.model Piggybak::Order do
          label "Order"
          navigation_label "Orders"
          weight -1
          object_label_method :admin_label

          show do
            field :status
            field :total do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :total_due do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :created_at
            field :email
            field :phone

            field :user if defined?(User)

            field :line_items
            field :billing_address
            field :shipping_address
            field :order_notes do
              pretty_value do
                value.inject([]) { |arr, o| arr << o.details }.join("<br /><br />").html_safe
              end
            end
            field :ip_address
            field :user_agent
          end
          list do
            field :id
            field :billing_address do
              label "Billing Name"
              pretty_value do
                "#{value.lastname}, #{value.firstname}"
              end
              searchable [:firstname, :lastname]
              sortable false
            end
            field :total do
              formatted_value do
                "$%.2f" % value
              end
            end
            field :created_at do
              strftime_format "%d-%m-%Y"
            end
            field :status
          end
          edit do
            field :recorded_changer, :hidden do
              partial "recorded_changer"
            end
            field :status do
              visible do
                !bindings[:object].new_record?
              end
              read_only do
                !bindings[:object].new_record?
              end
            end

            field :details do
              partial "order_details"
              help ""
              visible do
                !bindings[:object].new_record?
              end
            end

            field :user if defined?(User)
            field :email
            field :phone
            field :ip_address do
              partial "ip_address"
            end
            field :user_agent do
              read_only true
            end
            field :billing_address do
              active true
              help "Required"
            end
            field :shipping_address do
              active true
              help "Required"
            end
            field :line_items do
              active true
              help ""
            end
            field :order_notes do
              active true
            end
          end
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
