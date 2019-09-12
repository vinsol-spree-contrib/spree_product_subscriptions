class CreateStiFromSubscription < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_subscriptions, :type, :string
  end
end
