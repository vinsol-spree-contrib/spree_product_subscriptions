module SpreeProductSubscriptions
  module OrdersControllerDecorator
    def self.prepend(base)
      base.before_action :add_subscription_fields, only: :populate, if: -> { params[:subscribe].present? }
      base.before_action :restrict_guest_subscription, only: :update, unless: :spree_current_user
    end

    private

    def restrict_guest_subscription
      redirect_to login_path, error: ::Spree.t(:required_authentication) if @order.subscriptions.present?
    end

    def add_subscription_fields
      is_subscribed = params.fetch(:subscribe, '').present?

      existing_options = {options: params.fetch(:options, {}).permit!}
      updated_subscription_params = params.fetch(:subscription, {}).merge({subscribe: is_subscribed}).permit!
      existing_options[:options].merge!(updated_subscription_params)
      updated_params = params.merge!(existing_options)
      updated_params
    end
  end
end

::Spree::OrdersController.prepend(::SpreeProductSubscriptions::OrdersControllerDecorator)
