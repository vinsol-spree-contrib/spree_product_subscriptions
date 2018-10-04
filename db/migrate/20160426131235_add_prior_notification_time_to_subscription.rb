class AddPriorNotificationTimeToSubscription < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_subscriptions, :prior_notification_days_gap, :integer, default: 7, null: false
  end
end
