Spree::Order.class_eval do
  def payment_required?
    false
  end

  def payment?
    false
  end
end