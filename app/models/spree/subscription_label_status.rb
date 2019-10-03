module Spree
  class SubscriptionLabelStatus < Spree::Base

    has_many :product_subscription_label_statuses, class_name: "Spree::ProductSubscriptionLabelStatus", dependent: :destroy
    has_many :subscriptions, class_name: "Spree::Subscription", dependent: :restrict_with_error

    validates :title, presence: true
    validates :label_status, presence: true, inclusion:
      { in: Spree::Label.state_machine.states.map(&:name),
        message: '%{value} is not a valid label status' }
    with_options allow_blank: true do
      validates :title, uniqueness: { case_sensitive: false }
    end

  end
end
