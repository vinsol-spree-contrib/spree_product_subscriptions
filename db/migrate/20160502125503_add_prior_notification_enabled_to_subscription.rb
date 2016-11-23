class AddPriorNotificationEnabledToSubscription < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :prior_notification_enabled, :boolean, default: true, null: false
    add_index :spree_subscriptions, :prior_notification_enabled
  end
end
