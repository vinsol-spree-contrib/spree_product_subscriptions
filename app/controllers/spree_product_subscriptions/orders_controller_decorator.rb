module SpreeProductSubscriptions::OrdersControllerDecorator  

  def self.prepended(base)
    base.before_action :restrict_guest_subscription, only: :update, unless: :spree_current_user
  end

  private

    def restrict_guest_subscription
      redirect_to login_path, error: Spree.t(:required_authentication) if @order.subscriptions.present?
    end
end

Spree::OrdersController.prepend SpreeProductSubscriptions::OrdersControllerDecorator
