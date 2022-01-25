module SpreeProductSubscriptions
  module UsersControllerDecorator
    def self.prepended(base)
      base.before_action :load_subscriptions, only: :show
    end

    private

    def load_subscriptions
      @orders = @user.orders.complete.order(completed_at: :desc)
      @subscriptions = ::Spree::Subscription
        .active
        .order(created_at: :desc)
        .with_parent_orders(@orders)
        .map{ |s| s.becomes(::Spree::Subscription) }
    end
  end
end

::Spree::UsersController.prepend(::SpreeProductSubscriptions::UsersControllerDecorator)
