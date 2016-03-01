class CreateSpreeProductSubscriptionFrequencies < ActiveRecord::Migration
  def change
    create_table :spree_product_subscription_frequencies do |t|
      t.references :product, index: true, foreign_key: true
      t.references :subscription_frequency, foreign_key: true
    end
  end
end
