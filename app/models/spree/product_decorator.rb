Spree::Product.class_eval do

  has_many :subscriptions, through: :variants_including_master, source: :subscriptions, dependent: :restrict_with_error
  has_many :product_subscription_frequencies, class_name: "Spree::ProductSubscriptionFrequency", dependent: :destroy
  has_many :subscription_frequencies, through: :product_subscription_frequencies, dependent: :destroy

  alias_attribute :subscribable, :is_subscribable

  self.whitelisted_ransackable_attributes += %w( subscribable )

  scope :subscribable, -> { where(subscribable: true) }

  validates :subscription_frequencies, length: { minimum: 1, message: "are atleast one required" }

end
