Spree::Product.class_eval do

  has_many :subscriptions, through: :variants_including_master, source: :subscriptions, dependent: :restrict_with_error

  has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency", dependent: :destroy
  has_many :subscription_frequencies, through: :product_subscription_frequencies, dependent: :destroy

  has_many :product_subscription_label_statuses, class_name: "Spree::ProductSubscriptionLabelStatus", dependent: :destroy
  has_many :subscription_label_statuses, through: :product_subscription_label_statuses, dependent: :destroy

  alias_attribute :subscribable, :is_subscribable

  self.whitelisted_ransackable_attributes += %w( is_subscribable )

  scope :subscribable, -> { where(subscribable: true) }

  # validates :subscription_frequencies, presence: true, if: :subscribable?

end
