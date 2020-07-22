class SubscriptionAbility
  include CanCan::Ability

  def initialize(user)
    can :create, ::Spree::Subscription
    can :read, ::Spree::Subscription if user.orders.pluck(:id).include?(:parent_order_id)
    can :update, ::Spree::Subscription if user.orders.pluck(:id).include?(:parent_order_id)
  end
end
