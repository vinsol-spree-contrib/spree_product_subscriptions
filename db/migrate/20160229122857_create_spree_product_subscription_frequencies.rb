class CreateSpreeProductSubscriptionFrequencies < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_product_subscription_frequencies do |t|
      t.references :product, index: true
      t.references :subscription_frequency, index: { name: 'index_spree_product_subscription_frequency_id'}
    end
  end
end
