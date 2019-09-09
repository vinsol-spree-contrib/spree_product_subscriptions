class AddPauseAndDayColumnToSpreeSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_subscriptions, :pause, :boolean, default: false
    add_column :spree_subscriptions, :delivery_day, :integer
  end
end
