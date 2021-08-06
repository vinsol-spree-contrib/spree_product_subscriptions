module Spree::OrderDecorator
  def self.prepended(base)
    base.has_one :order_subscription, class_name: "Spree::OrderSubscription", dependent: :destroy
    base.has_one :parent_subscription, through: :order_subscription, source: :subscription
    base.has_many :subscriptions, class_name: "Spree::Subscription",
                           foreign_key: :parent_order_id,
                           dependent: :restrict_with_error

    base.after_update :update_subscriptions

    base.state_machine.after_transition to: :complete, do: :enable_subscriptions, if: :any_disabled_subscription?
  end

  def available_payment_methods
    @available_payment_methods ||= Spree::PaymentMethod.active.available_on_front_end

    return @available_payment_methods if sap_customer_id

    @available_payment_methods.reject { |m| m.type == 'Spree::PaymentMethod::PurchaseOrder' }
  end

  private

  def enable_subscriptions
    payment_source = if payments.any?
                       payments.first.source
                     else
                       merge_order.payments.last.source
                     end
    subscriptions.each do |subscription|
      subscription.update(
        source: payment_source,
        enabled: true,
        ship_address: ship_address.clone,
        bill_address: bill_address.clone
      )
    end
  end

  def any_disabled_subscription?
    subscriptions.disabled.any?
  end

  def update_subscriptions
    line_items.each do |line_item|
      if line_item.subscription_attributes_present?
        subscriptions.find_by(variant: line_item.variant).update(line_item.updatable_subscription_attributes)
      end
    end
  end
end

::Spree::Order.prepend(Spree::OrderDecorator)
