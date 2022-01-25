module SpreeProductSubscriptions
  module ProductDecorator
    def self.prepended(base)
      base.has_many :subscriptions, through: :variants_including_master, source: :subscriptions, dependent: :restrict_with_error

      base.has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency", dependent: :destroy
      base.has_many :subscription_frequencies, through: :product_subscription_frequencies, dependent: :destroy

      base.has_many :product_subscription_label_statuses, class_name: "Spree::ProductSubscriptionLabelStatus", dependent: :destroy
      base.has_many :subscription_label_statuses, through: :product_subscription_label_statuses, dependent: :destroy

      base.alias_attribute :subscribable, :is_subscribable

      base.scope :subscribable, -> { where(subscribable: true) }

      base.whitelisted_ransackable_attributes += %w( is_subscribable )

      base.validate :subscribable_options, on: :update, if: :subscribable?
    end

    private

    def subscribable_options
      unless subscription_label_statuses.present? || subscription_frequencies.present?
        errors.add(:subscribable, 'please select a subscription type')
      end
    end
  end
end

::Spree::Product.prepend(::SpreeProductSubscriptions::ProductDecorator)
