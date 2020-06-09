module SpreeProductSubscriptions::VariantDecorator


  def self.prepended(base)
    base.has_many :subscriptions, class_name: "Spree::Subscription", dependent: :restrict_with_error
    base.delegate :variants_including_master, to: :product, prefix: true
    base.alias_method :product_variants, :product_variants_including_master  
  end

end

Spree::Variant.prepend SpreeProductSubscriptions::VariantDecorator
