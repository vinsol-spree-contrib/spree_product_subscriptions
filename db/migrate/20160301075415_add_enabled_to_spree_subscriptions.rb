class AddEnabledToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_column :spree_subscriptions, :enabled, :boolean, default: false
  end
end
