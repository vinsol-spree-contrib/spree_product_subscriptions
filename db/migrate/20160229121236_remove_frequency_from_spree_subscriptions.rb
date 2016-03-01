class RemoveFrequencyFromSpreeSubscriptions < ActiveRecord::Migration
  def change
    remove_column :spree_subscriptions, :frequency, :string
  end
end
