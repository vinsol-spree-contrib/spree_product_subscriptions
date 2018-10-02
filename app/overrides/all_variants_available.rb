Spree::Variant.class_eval do
  def available?
    true
  end

  module ClassMethods
    def random_variant
      where('woo_id is not null').order('RAND()').first
    end
  end
end