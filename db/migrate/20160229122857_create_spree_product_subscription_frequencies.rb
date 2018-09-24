class CreateSpreeProductSubscriptionFrequencies < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_product_subscription_frequencies do |t|
      t.references :product, index: true
      t.references :subscription_frequency
    end
  end
end
