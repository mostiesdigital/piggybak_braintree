module PiggybakBraintree
  module OrderDecorator
    extend ActiveSupport::Concern

    included do
      def add_line_items(cart)
        cart.update_quantities

        cart.sellables.each do |item|
          self.line_items << Piggybak::LineItem.new({
                                                      :sellable_id => item[:sellable].id,
                                                      :unit_price => item[:sellable].price,
                                                      :price => item[:sellable].price*item[:quantity],
                                                      :description => item[:sellable].description,
                                                      :quantity => item[:quantity],
                                                      :start_date => item[:start_date]
                                                    })
        end
      end
    end
  end
end
