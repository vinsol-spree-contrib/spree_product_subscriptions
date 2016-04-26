require 'spec_helper'

describe Spree::Promotion::Rules::SubscribableProduct, type: :model do
  let(:rule) { Spree::Promotion::Rules::SubscribableProduct.new(rule_options) }
  let(:rule_options) { {} }

  context "#eligible?(order)" do
    let(:order) { Spree::Order.new }

    it "should be eligible if there are no products" do
      allow(rule).to receive_messages(eligible_products: [])
      expect(rule).to be_eligible(order)
    end

    before do
      3.times { |i| instance_variable_set("@product#{i}", mock_model(Spree::Product)) }
      3.times { |i| instance_variable_set("@variant#{i}", mock_model(Spree::Variant)) }
      1.times { |i| instance_variable_set("@subscription#{i}", mock_model(Spree::Subscription)) }
    end

    context "with 'any' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: 'any') }
      let(:subscriptions) { [@subscription1] }
      let(:variants) { [@variant1, @variant2] }

      it "should be eligible if any of the products is in eligible products" do
        allow(order).to receive_messages(:subscriptions => subscriptions)
        allow(subscriptions).to receive_messages(map: variants)
        allow(variants).to receive_messages(map: [@product1, @product2])
        allow(rule).to receive_messages(:eligible_products => [@product2, @product3])
        expect(rule).to be_eligible(order)
      end

      context "when none of the products are eligible products" do
        before do
          allow(order).to receive_messages(:subscriptions => subscriptions)
          allow(subscriptions).to receive_messages(map: variants)
          allow(variants).to receive_messages(map: [@product1])
          allow(rule).to receive_messages(eligible_products: [@product2, @product3])
        end
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).
            to eq "You need to add an applicable product before applying this coupon code."
        end
      end
    end

    context "with 'all' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: 'all') }
      let(:subscriptions) { [@subscription1] }
      let(:variants) { [@variant1, @variant2] }

      it "should be eligible if all of the eligible products are ordered" do
        allow(order).to receive_messages(:subscriptions => subscriptions)
        allow(subscriptions).to receive_messages(map: variants)
        allow(variants).to receive_messages(map: [@product2, @product3])
        allow(rule).to receive_messages(:eligible_products => [@product2, @product3])
        expect(rule).to be_eligible(order)
      end

      context "when any of the eligible products is not ordered" do
        before do
          allow(order).to receive_messages(:subscriptions => subscriptions)
          allow(subscriptions).to receive_messages(map: variants)
          allow(variants).to receive_messages(map: [@product2, @product3])
          allow(rule).to receive_messages(eligible_products: [@product1, @product2, @product3])
        end
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).
            to eq "This coupon code can't be applied because you don't have all of the necessary products in your cart."
        end
      end
    end

    context "with 'none' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: 'none') }
      let(:subscriptions) { [@subscription1] }
      let(:variants) { [@variant1, @variant2] }

      it "should be eligible if none of the order's products are in eligible products" do
        allow(order).to receive_messages(:subscriptions => subscriptions)
          allow(subscriptions).to receive_messages(map: variants)
          allow(variants).to receive_messages(map: [@product1])
        allow(rule).to receive_messages(:eligible_products => [@product2, @product3])
        expect(rule).to be_eligible(order)
      end

      context "when any of the order's products are in eligible products" do
        before do
          allow(order).to receive_messages(:subscriptions => subscriptions)
          allow(subscriptions).to receive_messages(map: variants)
          allow(variants).to receive_messages(map: [@product1, @product2])
          allow(rule).to receive_messages(eligible_products: [@product2, @product3])
        end
        it { expect(rule).not_to be_eligible(order) }
        it "sets an error message" do
          rule.eligible?(order)
          expect(rule.eligibility_errors.full_messages.first).
            to eq "Your cart contains a product that prevents this coupon code from being applied."
        end
      end
    end
  end

  describe '#actionable?' do
    subject do
      rule.actionable?(line_item)
    end

    let(:rule_line_item) { Spree::LineItem.new(product: rule_product) }
    let(:other_line_item) { Spree::LineItem.new(product: other_product) }

    let(:rule_options) { super().merge(subscribable_products: [rule_product]) }
    let(:rule_product) { mock_model(Spree::Product) }
    let(:other_product) { mock_model(Spree::Product) }

    context "with 'any' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: 'any') }

      context 'for product in rule' do
        let(:line_item) { rule_line_item }
        it { should be_truthy }
      end

      context 'for product not in rule' do
        let(:line_item) { other_line_item }
        it { should be_falsey }
      end
    end

    context "with 'all' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: 'all') }

      context 'for product in rule' do
        let(:line_item) { rule_line_item }
        it { should be_truthy }
      end

      context 'for product not in rule' do
        let(:line_item) { other_line_item }
        it { should be_falsey }
      end
    end

    context "with 'none' match policy" do
      let(:rule_options) { super().merge(preferred_match_policy: 'none') }

      context 'for product in rule' do
        let(:line_item) { rule_line_item }
        it { should be_falsey }
      end

      context 'for product not in rule' do
        let(:line_item) { other_line_item }
        it { should be_truthy }
      end
    end
  end
end
