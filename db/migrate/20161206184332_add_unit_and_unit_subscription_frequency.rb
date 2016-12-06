class AddUnitAndUnitSubscriptionFrequency < ActiveRecord::Migration
  def change
    rename_column :spree_subscription_frequencies, :months_count, :units_count
    add_column :spree_subscription_frequencies, :unit, :integer, null: false, default: 2
  end
end
