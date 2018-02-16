class AddPaymentReferenceToSpreeSubscriptions < ActiveRecord::Migration[4.2]
  def change
    add_reference :spree_subscriptions, :source, index: true
  end
end
