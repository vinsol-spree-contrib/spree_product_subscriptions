class ChangePauseNullInSpreeSubscriptions < ActiveRecord::Migration[5.1]
  def up
    change_column_null :spree_subscriptions, :paused, false
    add_index :spree_subscriptions, :paused
  end

  def down
    change_column_null :spree_subscriptions, :paused, true
    remove_index :spree_subscriptions, :paused
  end
end
