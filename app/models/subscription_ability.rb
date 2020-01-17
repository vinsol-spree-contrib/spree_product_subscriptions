class SubscriptionAbility
  include CanCan::Ability

  def initialize(user)
    if user.respond_to?(:has_spree_role?) && user.has_spree_role?('admin')
      can :manage, :all
    else
      can :create, ::Spree::Subscription
      can :read, ::Spree::Subscription do |subscription|
        subscription.parent_order.user == user
      end
      can :update, ::Spree::Subscription do |subscription|
        subscription.parent_order.user == user
      end
    end
  end
end