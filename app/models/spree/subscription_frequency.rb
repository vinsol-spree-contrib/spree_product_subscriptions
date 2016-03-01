module Spree
  class SubscriptionFrequency < Spree::Base

    has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency",
                                                dependent: :destroy

    validates :title, presence: true
    validates :title, uniqueness: { case_sensitive: false }, allow_blank: true

  end
end
