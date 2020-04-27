require 'spec_helper'

describe Spree::LineItem, type: :model do

  let(:order) { create(:completed_order_with_totals) }
  let(:frequency) { create(:monthly_subscription_frequency, title: "monthly1") }
  let(:variant) { create(:base_variant) }
  let!(:line_item_without_subscription_attributes) { create(:line_item, order: order, variant: variant) }
  let!(:line_item_with_subscription_attributes) { create(:line_item, order: order, subscription_frequency_id: 1) }
  let!(:active_subscription) { create(:valid_subscription, enabled: true, variant: line_item_with_subscription_attributes.variant, subscription_frequency_id: frequency.id, parent_order: order) }
  let!(:line_item_without_subscription) { create(:line_item) }

  describe "callbacks" do
    it { is_expected.to callback(:create_subscription!).after(:create).if(:subscribable?) }
    it { is_expected.to callback(:update_subscription_quantity).after(:update).if(:can_update_subscription_quantity?) }
    it { is_expected.to callback(:update_subscription_attributes).after(:update).if(:can_update_subscription_attributes?) }
    it { is_expected.to callback(:destroy_associated_subscription!).after(:destroy).if(:subscription?) }
  end

  describe "attr_accessors" do
    it { is_expected.to respond_to :subscribe }
    it { is_expected.to respond_to :subscribe= }
    it { is_expected.to respond_to :subscription_frequency_id }
    it { is_expected.to respond_to :subscription_frequency_id= }
  end

  describe "methods" do
    context "#subscription_attributes_present?" do
      it { expect(line_item_with_subscription_attributes).to be_subscription_attributes_present }
      it { expect(line_item_without_subscription_attributes).to_not be_subscription_attributes_present }
    end

    context "#updatable_subscription_attributes" do
      it { expect(line_item_with_subscription_attributes.updatable_subscription_attributes).to eq({ subscription_frequency_id: 1 }) }
    end

    context "#subscription" do
      it { expect(line_item_with_subscription_attributes.send :subscription).to eq active_subscription }
      it { expect(line_item_without_subscription.send :subscription).to be_nil }
    end

    context "#subscription?" do
      it { expect(line_item_without_subscription.send :subscription?).to eq false }
      it { expect(line_item_with_subscription_attributes.send :subscription?).to eq true }
    end

    context "#can_update_subscription_attributes?" do
      it { expect(line_item_without_subscription_attributes.send :can_update_subscription_attributes?).to eq false }
      it { expect(line_item_with_subscription_attributes.send :can_update_subscription_attributes?).to eq true }
    end

    context "#can_update_subscription_quantity?" do
      context "when subscription not present" do
        it { expect(line_item_without_subscription.send :can_update_subscription_quantity?).to eq false }
      end

      context "when subscription is present but quantity not changed" do
        it { expect(line_item_with_subscription_attributes.send :can_update_subscription_quantity?).to eq false }
      end

      context "when subscription is present and quantity is changed" do
        before { line_item_with_subscription_attributes.quantity = 5 }
        it { expect(line_item_with_subscription_attributes.send :can_update_subscription_quantity?).to eq true }
      end
    end

    context "#destroy_associated_subscription!" do
      it { expect(line_item_with_subscription_attributes.send :destroy_associated_subscription!).to eq active_subscription }
    end

    context "#update_subscription_quantity" do
      def update_line_item_subscription_quantity
        line_item_with_subscription_attributes.quantity = 9
        line_item_with_subscription_attributes.send :update_subscription_quantity
      end
      it { expect { update_line_item_subscription_quantity }.to change { active_subscription.reload.quantity }.from(2).to(9) }
    end

    context "#update_subscription_attributes" do
      context "when subscription attributes are changed" do
        def update_line_item_subscription_attributes
          line_item_with_subscription_attributes.subscription_frequency_id = 2
          line_item_with_subscription_attributes.send :update_subscription_attributes
        end
        it { expect { update_line_item_subscription_attributes }.to change{ active_subscription.reload.subscription_frequency_id }.from(1).to(2) }
      end
    end

    context "#subscribable?" do
      context "when subscribe is present" do
        before { line_item_with_subscription_attributes.subscribe = true }
        it { expect(line_item_with_subscription_attributes.send :subscribable?).to eq true }
      end
      context "when subscribe is not present" do
        it { expect(line_item_with_subscription_attributes.send :subscribable?).to eq false }
      end
    end

    context "#subscription_attributes" do
      it { expect(line_item_with_subscription_attributes.send :subscription_attributes).to eq({
        subscription_frequency_id: 1,
        variant: active_subscription.variant,
        quantity: 1,
        price: active_subscription.variant.price
        }) }
    end

    context "#create_subscription!" do
      def create_subscription
        line_item_without_subscription_attributes.subscription_frequency_id = frequency.id
        line_item_without_subscription_attributes.send :create_subscription!
      end
      it { expect { create_subscription }.to change { order.subscriptions.count }.by 1 }
    end
  end

end
