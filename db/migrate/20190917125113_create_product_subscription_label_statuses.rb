class CreateProductSubscriptionLabelStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_product_subscription_label_statuses do |t|
      t.references :product, index: true
      t.references :subscription_label_status
    end

    add_reference :spree_subscriptions, :subscription_label_status, index: true
  end
end
