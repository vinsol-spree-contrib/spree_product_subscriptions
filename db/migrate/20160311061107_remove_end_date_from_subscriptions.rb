class RemoveEndDateFromSubscriptions < ActiveRecord::Migration[5.1]
  def change
    remove_column :spree_subscriptions, :end_date, :datetime
  end
end
