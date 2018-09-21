class AddPolymorphicSourceReferenceToSubscription < ActiveRecord::Migration[5.1]
  def change
    remove_reference :spree_subscriptions, :source
    add_reference :spree_subscriptions, :source, polymorphic: true
  end
end
