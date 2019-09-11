require 'spec_helper'

RSpec.describe Spree::SubscriptionNotifier do

  let(:active_subscription) { mock_model(Spree::Subscription, id: 1, enabled: true, next_occurrence_at: Time.current) }
  let(:order) { create(:completed_order_with_totals) }
  let(:subscription_frequency) { mock_model(Spree::SubscriptionFrequency, id: 1, title: 'monthly', months_count: 1) }
  let(:variant) { mock_model(Spree::Variant) }
  let(:product) { mock_model(Spree::Product) }

  describe 'notify_for_next_delivery' do

    let(:mail) { described_class.notify_for_next_delivery(active_subscription) }
    before do
      allow(active_subscription).to receive(:parent_order).and_return(order)
      allow(active_subscription).to receive(:frequency).and_return(subscription_frequency)
      allow(active_subscription).to receive(:variant).and_return(variant)
      allow(active_subscription).to receive(:number_of_deliveries_left).and_return(1)
      allow(variant).to receive(:product).and_return(product)
      allow(variant).to receive(:options_text).and_return('')
    end

    it 'renders the subject' do
      expect(mail.subject).to eq(I18n.t(:subject, scope: [:spree, :subscription_notifier, :notify_for_next_delivery],
        number: active_subscription.number, frequency: active_subscription.frequency.title.capitalize))
    end

    it 'renders the receiver email' do
      expect(mail.to).to eq([active_subscription.parent_order.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eq([Spree::SubscriptionNotifier.default[:from]])
    end

    it 'assigns @subscription' do
      expect(mail.body.encoded).to match(active_subscription.parent_order.email)
    end
  end
end
