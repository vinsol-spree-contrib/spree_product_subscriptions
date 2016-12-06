module Spree
  class SubscriptionFrequency < Spree::Base
    enum unit: {
      weeks: 1,
      months: 2
    }

    has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency",
                                                dependent: :destroy
    has_many :subscriptions, class_name: "Spree::Subscription", dependent: :restrict_with_error

    validates :title, :units_count, :unit, presence: true
    with_options allow_blank: true do
      validates :units_count, numericality: { greater_than: 0, only_integer: true }
      validates :title, uniqueness: { case_sensitive: false }
    end

    def next_occurrence_from(date)
      date + self.units_count.send(self.unit)
    end

  end
end
