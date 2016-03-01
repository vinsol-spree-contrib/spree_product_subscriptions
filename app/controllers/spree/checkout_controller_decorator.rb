Spree::CheckoutController.class_eval do

  after_action :enable_subscriptions, only: :update, if: -> { @order.completed? }

  private

    def enable_subscriptions
      @order.subscriptions.each do |subscription|
        subscription.update(source: @order.payments.from_credit_card.first.source,
          enabled: true, ship_address: @order.ship_address, bill_address: @order.bill_address)
      end
    end

end
