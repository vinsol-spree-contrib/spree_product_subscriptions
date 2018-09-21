class CreateSpreeSubscriptions < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_subscriptions do |t|
      t.references :variant, index: true
      t.integer :quantity
      t.string :frequency
      t.references :parent_order, index: true
      t.references :ship_address, index: true
      t.references :bill_address, index: true
      t.date :last_recurrence_at, index: true
      t.date :end_date, index: true
      t.date :cancelled_at, index: true
      t.decimal :price, precision: 8, scale: 2

      t.timestamps null: false
    end
  end
end
