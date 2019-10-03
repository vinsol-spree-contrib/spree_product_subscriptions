Spree::UsersController.class_eval do

  before_action :load_subscriptions, only: :show

  private

    def load_subscriptions
      @orders = @user.orders.complete.order(completed_at: :desc)
      @subscriptions = Spree::Subscription.active.order(created_at: :desc).with_parent_orders(@orders).map{ |s| s.becomes(Spree::Subscription) }
    end

end
