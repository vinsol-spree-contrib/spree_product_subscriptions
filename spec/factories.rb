FactoryBot.define do
  factory :monthly_subscription_frequency, class: Spree::SubscriptionFrequency do
    title { 'monthly' }
    months_count { 1 }
  end

  factory :nil_attributes_subscription, class: Spree::Subscriptions::Period do
  end

  factory :valid_subscription, class: Spree::Subscriptions::Period do
    price { 20.00 }
    quantity { 2 }
    association :variant, factory: :base_variant
    association :parent_order, factory: :completed_order_with_totals
    association :ship_address, factory: :address
    association :bill_address, factory: :address
    association :source, factory: :credit_card
  end
end
