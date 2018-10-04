class ChangeNamesOfTablesAndColumns < ActiveRecord::Migration[5.1]
  def up
    change_column_default :spree_subscriptions, :quantity, 0
    change_column_null :spree_subscriptions, :quantity, false
    change_column_null :spree_subscription_frequencies, :title, false
    change_column :spree_subscriptions, :last_recurrence_at, :datetime
    change_column :spree_subscriptions, :end_date, :datetime
    change_column :spree_subscriptions, :cancelled_at, :datetime
    change_column :spree_order_subscriptions, :failed_at, :datetime
    rename_table :spree_order_subscriptions, :spree_orders_subscriptions
    rename_column :spree_products, :subscribable, :is_subscribable
    rename_column :spree_subscriptions, :last_recurrence_at, :last_occurrence_at
  end

  def down
    change_column_default :spree_subscriptions, :quantity, nil
    change_column_null :spree_subscriptions, :quantity, true
    change_column_null :spree_subscription_frequencies, :string, true
    change_column :spree_subscriptions, :last_occurrence_at, :date
    change_column :spree_subscriptions, :end_date, :date
    change_column :spree_subscriptions, :cancelled_at, :date
    change_column :spree_orders_subscriptions, :failed_at, :date
    rename_table :spree_orders_subscriptions, :spree_order_subscriptions
    rename_column :spree_subscriptions, :last_occurrence_at, :last_recurrence_at
    rename_column :spree_products, :is_subscribable, :subscribable
  end
end
