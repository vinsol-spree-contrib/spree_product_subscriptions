module Spree
  class Subscription < Spree::Base

    belongs_to :ship_address, class_name: "Spree::Address"
    belongs_to :bill_address, class_name: "Spree::Address"
    belongs_to :parent_order, class_name: "Spree::Order"
    belongs_to :variant, inverse_of: :subscriptions
    belongs_to :frequency, foreign_key: :subscription_frequency_id, class_name: "Spree::SubscriptionFrequency"
    belongs_to :source, class_name: "Spree::CreditCard"

    has_many :orders_subscriptions, class_name: "Spree::OrdersSubscription", dependent: :destroy
    has_many :orders, through: :order_subscriptions

    scope :disabled, -> { where(enabled: false) }

    with_options allow_blank: true do
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :quantity, numericality: { greater_than: 0, only_integer: true }
      validates :parent_order, uniqueness: { scope: :variant }
    end
    with_options presence: true do
      validates :quantity, :end_date, :price
      validates :variant, :parent_order, :frequency
      validates :ship_address, :bill_address, :last_occurrence_at, :source, if: :enabled?
    end

    before_validation :set_last_occurrence_at, if: :enabled?

    private

      def set_last_occurrence_at
        self.last_occurrence_at = Time.current
      end

  end
end
