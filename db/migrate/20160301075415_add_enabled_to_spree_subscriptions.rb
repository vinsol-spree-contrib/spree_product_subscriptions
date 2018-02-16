class AddEnabledToSpreeSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_subscriptions, :enabled, :boolean, default: false
  end
end
