class AddDeliveryNumberToSpreeSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_subscriptions, :delivery_number, :integer
  end
end
