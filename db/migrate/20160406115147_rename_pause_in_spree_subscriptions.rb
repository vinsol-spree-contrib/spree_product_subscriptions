class RenamePauseInSpreeSubscriptions < ActiveRecord::Migration[4.2]
  def up
    rename_column :spree_subscriptions, :pause, :paused
  end

  def down
    rename_column :spree_subscriptions, :paused, :pause
  end
end
