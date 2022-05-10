module Spree
  class SubscriptionLabelStatus < Spree::Base
    has_many :product_subscription_label_statuses, class_name: "Spree::ProductSubscriptionLabelStatus", dependent: :destroy
    has_many :subscriptions, class_name: "Spree::Subscriptions::LabelStatus", dependent: :restrict_with_error

    validates :title, :label_status, presence: true

    with_options allow_blank: true do
      validates :title, uniqueness: { case_sensitive: false }
    end
  end
end
