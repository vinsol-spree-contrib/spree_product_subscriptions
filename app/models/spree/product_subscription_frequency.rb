module Spree
  class ProductSubscriptionFrequency < Spree::Base

    belongs_to :product, class_name: "Spree::Product"
    belongs_to :subscription_frequency, class_name: "Spree::SubscriptionFrequency"

    validates :product, :subscription_frequency, presence: true

  end
end
