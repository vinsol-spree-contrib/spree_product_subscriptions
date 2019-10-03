class DeleteDeliveryNumber < ActiveRecord::Migration[4.2]
  def change
  	remove_column :spree_subscriptions, :delivery_number, :integer
  end
end
