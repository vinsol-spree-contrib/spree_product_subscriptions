module SpreeProductSubscriptions
  module Admin
    module PaymentsControllerDecorator

      private

      def load_data
        @amount = params[:amount] || load_order.total
        @payment_methods = available_payment_methods
        @payment_method = @payment.try(:payment_method) || @payment_methods.first
      end

      def available_payment_methods
        @order.subscriptions.any? ? ::Spree::Gateway.available_on_back_end : ::Spree::PaymentMethod.available_on_back_end
      end
    end
  end
end

::Spree::Admin::PaymentsController.prepend(::SpreeProductSubscriptions::Admin::PaymentsControllerDecorator)
