class AddEnabledToSpreeSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_subscriptions, :enabled, :boolean, default: false
  end
end
