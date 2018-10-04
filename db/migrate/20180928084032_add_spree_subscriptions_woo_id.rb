class AddSpreeSubscriptionsWooId < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_subscriptions, :woo_id, :integer
    add_index :spree_subscriptions, :woo_id, unique: true
  end
end
