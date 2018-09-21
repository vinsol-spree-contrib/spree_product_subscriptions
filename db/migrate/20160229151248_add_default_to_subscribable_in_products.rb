class AddDefaultToSubscribableInProducts < ActiveRecord::Migration[5.1]
  def up
    change_column_default :spree_products, :subscribable, false
  end

  def down
    change_column_default :spree_products, :subscribable, nil
  end
end
