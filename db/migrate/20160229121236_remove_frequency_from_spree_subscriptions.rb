class RemoveFrequencyFromSpreeSubscriptions < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_subscriptions, :frequency, :string
  end
end
