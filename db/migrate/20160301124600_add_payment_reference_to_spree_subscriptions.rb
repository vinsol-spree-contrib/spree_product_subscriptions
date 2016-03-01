class AddPaymentReferenceToSpreeSubscriptions < ActiveRecord::Migration
  def change
    add_reference :spree_subscriptions, :source, index: true
  end
end
