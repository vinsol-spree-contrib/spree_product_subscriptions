module Spree::ProductDecorator
  def self.prepended(base)
    base.has_many :subscriptions, through: :variants_including_master, source: :subscriptions, dependent: :restrict_with_error

    base.has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency", dependent: :destroy
    base.has_many :subscription_frequencies, through: :product_subscription_frequencies, dependent: :destroy

    base.has_many :product_subscription_label_statuses, class_name: "Spree::ProductSubscriptionLabelStatus", dependent: :destroy
    base.has_many :subscription_label_statuses, through: :product_subscription_label_statuses, dependent: :destroy

    base.alias_attribute :subscribable, :is_subscribable

    base.scope :subscribable, -> { where(subscribable: true) }

    base.whitelisted_ransackable_attributes += %w( is_subscribable )
  end
  # validates :subscription_frequencies, presence: true, if: :subscribable?
end

::Spree::Product.prepend(Spree::ProductDecorator)
