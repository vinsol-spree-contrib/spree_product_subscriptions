require 'spec_helper'

describe Spree::Order, type: :model do

  let(:disabled_subscription) { create(:valid_subscription, enabled: false) }
  let(:subscriptions) { [disabled_subscription] }
  let(:order_with_subscriptions) { create(:completed_order_with_pending_payment, subscriptions: subscriptions) }
  let(:incompleted_order) { create(:order_with_line_items, subscriptions: subscriptions, state: "confirm", payments: order_with_subscriptions.payments) }

  describe "associations" do
    it { is_expected.to have_one(:order_subscription).class_name("Spree::OrderSubscription").dependent(:destroy) }
    it { is_expected.to have_one(:parent_subscription).through(:order_subscription).source(:subscription) }
    it { is_expected.to have_many(:subscriptions).class_name("Spree::Subscription").with_foreign_key(:parent_order_id).dependent(:restrict_with_error) }
  end

  describe "callbacks" do
    it { is_expected.to callback(:update_subscriptions).after(:update) }
  end

  describe "methods" do
    context "#available_payment_methods" do
      let(:order_without_subscriptions) { create(:order_with_line_items) }
      let(:credit_card_payment_method) { create(:credit_card_payment_method) }
      let(:check_payment_method) { create(:check_payment_method) }
      context "order with subscriptions" do
        it { expect(order_with_subscriptions.available_payment_methods).to include credit_card_payment_method }
        it { expect(order_with_subscriptions.available_payment_methods).to_not include check_payment_method }
      end

      context "order without subscriptions" do
        it { expect(order_without_subscriptions.available_payment_methods).to include check_payment_method }
        it { expect(order_without_subscriptions.available_payment_methods).to include credit_card_payment_method }
      end
    end

    context "#any_disabled_subscription?" do
      it { expect(order_with_subscriptions.send :any_disabled_subscription?).to eq true  }
    end

    context "#enable_subscriptions" do
      it { expect { order_with_subscriptions.send :enable_subscriptions }.to change { order_with_subscriptions.subscriptions.disabled.count }.by -1 }
    end

    context "state machine" do
      it { expect { incompleted_order.next }.to change { incompleted_order.subscriptions.disabled.count }.by -1 }
    end
  end
end
