module Spree
  class Subscription < Spree::Base

    self.table_name = "spree_subscriptions"

    # with_options required: true do
      belongs_to :ship_address, class_name: "Spree::Address", inverse_of: :shipped_subscriptions
      belongs_to :bill_address, class_name: "Spree::Address", inverse_of: :billed_subscriptions
      belongs_to :parent_order, class_name: "Spree::Order", inverse_of: :parent_subscription
      belongs_to :variant, inverse_of: :subscriptions, class_name: "Spree::Variant"
      belongs_to :frequency, inverse_of: :subscriptions, foreign_key: :subscription_frequency_id, class_name: "Spree::SubscriptionFrequency"
      belongs_to :source, class_name: "Spree::CreditCard"
    # end

    with_options presence: true do
      validates :quantity, :end_date, :price
      validates :variant, :parent_order, :frequency
      validates :ship_address, :bill_address, :last_recurrence_at, :source, if: :enabled?
    end
    validates :parent_order, uniqueness: { scope: :variant }
    validates :price, numericality: { greater_than: 0 }
    validates :quantity, numericality: { greater_than: 0, only_integer: true }

    before_validation :set_last_recurrence_at, if: :enabled?

    private

      def set_last_recurrence_at
        self.last_recurrence_at = Time.now
      end

  end
end
