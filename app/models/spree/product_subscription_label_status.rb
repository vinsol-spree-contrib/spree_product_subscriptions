module Spree
  class ProductSubscriptionLabelStatus < Spree::Base

    belongs_to :product, class_name: "Spree::Product"
    belongs_to :subscription_label_status, class_name: "Spree::SubscriptionLabelStatus"

    validates :product, :subscription_label_status, presence: true
    validates :product, uniqueness: { scope: :subscription_label_status }

  end
end
