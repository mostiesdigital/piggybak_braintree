module PiggybakBraintree
  module OrdersControllerDecorator
    extend ActiveSupport::Concern

    included do
      def submit
        response.headers['Cache-Control'] = 'no-cache'
        @cart = Piggybak::Cart.new(request.cookies["cart"])

        if request.post?
          logger = Logger.new("#{Rails.root}/#{Piggybak.config.logging_file}")

          begin
            ActiveRecord::Base.transaction do
              @order = Piggybak::Order.new(orders_params)
              @order.create_payment_shipment

              if Piggybak.config.logging
                clean_params = params[:order].clone
                clean_params[:line_items_attributes].each do |k, li_attr|
                  if li_attr[:line_item_type] == "payment" && li_attr.has_key?(:payment_attributes)
                    if li_attr[:payment_attributes].has_key?(:number)
                      li_attr[:payment_attributes][:number] = li_attr[:payment_attributes][:number].mask_cc_number
                    end
                    if li_attr[:payment_attributes].has_key?(:verification_value)
                      li_attr[:payment_attributes][:verification_value] = li_attr[:payment_attributes][:verification_value].mask_csv
                    end
                  end
                end
                logger.info "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order received with params #{clean_params.inspect}"
              end
              @order.initialize_user(current_user)

              @order.ip_address = request.remote_ip
              @order.user_agent = request.user_agent
              @order.add_line_items(@cart)

              if Piggybak.config.logging
                logger.info "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order contains: #{cookies["cart"]} for user #{current_user ? current_user.email : 'guest'}"
              end

              if @order.save
                if Piggybak.config.logging
                  logger.info "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order saved: #{@order.inspect}"
                end

                cookies["cart"] = { :value => '', :path => '/' }
                session[:last_order] = @order.id
                redirect_to piggybak.receipt_url
              else
                if Piggybak.config.logging
                  logger.warn "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order failed to save #{@order.errors.full_messages} with #{@order.inspect}."
                end
                raise Exception, @order.errors.full_messages
              end
            end
          rescue Exception => e
            if Piggybak.config.logging
              logger.warn "#{request.remote_ip}:#{Time.now.strftime("%Y-%m-%d %H:%M")} Order exception: #{e.inspect}"
            end
            if @order.errors.empty?
              @order.errors[:base] << "Your order could not go through. Please try again."
            end
          end
        else
          @order = Piggybak::Order.new
          @order.create_payment_shipment
          @order.initialize_user(current_user)
          payment_method = ::PiggybakBraintree::PaymentCalculator::Braintree.new(@order.payment_method)
          payment_method.configure
          @client_token = payment_method.client_token
        end
      end
    end
  end
end
