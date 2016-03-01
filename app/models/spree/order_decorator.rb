Spree::Order.class_eval do

  has_one :order_subscription, class_name: "Spree::OrderSubscription"
  has_one :parent_subscription, through: :order_subscription, source: :subscription
  has_many :subscriptions, class_name: "Spree::Subscription", foreign_key: :parent_order_id

  def available_payment_methods
    payment_methods = Spree::PaymentMethod.where(active: true)
    if subscriptions.count > 0
      @available_payment_methods = payment_methods.where(name: "Credit Card")
    else
      @available_payment_methods ||= payment_methods
    end
  end

end
