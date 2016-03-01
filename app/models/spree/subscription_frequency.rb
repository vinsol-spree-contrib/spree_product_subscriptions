module Spree
  class SubscriptionFrequency < Spree::Base

    self.table_name = "spree_subscription_frequencies"

    has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency"
    has_many :subscriptions, class_name: "Spree::Subscription"

    validates :title, presence: true

  end
end
