class AddSubscriptionFrequencyReferenceToSpreSubscriptions < ActiveRecord::Migration
  def change
    add_reference :spree_subscriptions, :subscription_frequency, foreign_key: true
  end
end
