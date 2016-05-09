module Spree
  class SubscriptionPresenter

    def initialize(subscription)
      @subscription  = subscription
    end

    def delivery_count
      @subscription.delivery_number || Float::INFINITY
    end

  end
end