class SubscriptionAbility
  include CanCan::Ability

  def initialize(user)
    if user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
      can :manage, :all
    else
      can :create, ::Spree::Subscription
      can :read, ::Spree::Subscription if user.orders.pluck(:id).include?(:parent_order_id)
      can :update, ::Spree::Subscription if user.orders.pluck(:id).include?(:parent_order_id)
    end
  end
end
