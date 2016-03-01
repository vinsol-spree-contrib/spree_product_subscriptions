Spree::Variant.class_eval do

  has_many :subscriptions, class_name: "Spree::Subscription", dependent: :restrict_with_error

end
