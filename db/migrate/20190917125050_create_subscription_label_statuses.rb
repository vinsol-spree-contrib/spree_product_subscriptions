class CreateSubscriptionLabelStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_subscription_label_statuses do |t|
      t.string :title
      t.string :label_status

      t.timestamps null: false
    end
  end
end
