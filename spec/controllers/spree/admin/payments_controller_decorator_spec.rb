require "spec_helper"

describe Spree::Admin::PaymentsController, type: :controller do

  let(:order) { create(:completed_order_with_pending_payment) }
  let(:subscriptions) { double(ActiveRecord::Relation) }

  stub_authorization!

  def do_new
    spree_get :new, order_id: order.number
  end

  describe "method overrides" do

    let(:orders) { double(ActiveRecord::Relation) }
    let(:credit_card_payment_method) { create(:credit_card_payment_method) }
    let(:check_payment_method) { create(:check_payment_method) }
    let(:payment_methods) { [check_payment_method, credit_card_payment_method] }
    let(:payment_methods_without_check) { [credit_card_payment_method] }

    before do
      allow(Spree::Order).to receive(:find_by!).and_return(order)
      allow(order).to receive(:subscriptions).and_return(subscriptions)
    end

    describe "#load_data" do
      context "when subscriptions are present" do
        before do
          allow(subscriptions).to receive(:any?).and_return(true)
          allow(Spree::Gateway).to receive(:available_on_back_end).and_return(payment_methods_without_check)
        end

        context "expects to receive" do
          after { do_new }
          it { expect(Spree::Order).to receive(:find_by!).and_return(order) }
          it { expect(order).to receive(:subscriptions).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:any?).and_return(true) }
          it { expect(Spree::Gateway).to receive(:available_on_back_end).and_return(payment_methods_without_check) }
        end

        context "assigns" do
          before { do_new }
          it { expect(assigns(:payment_method)).to eq credit_card_payment_method }
        end
      end

      context "when subscriptions are not present" do
        before do
          allow(subscriptions).to receive(:any?).and_return(false)
          allow(Spree::PaymentMethod).to receive(:available_on_back_end).and_return(payment_methods)
        end

        context "expects to receive" do
          after { do_new }
          it { expect(Spree::Order).to receive(:find_by!).and_return(order) }
          it { expect(order).to receive(:subscriptions).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:any?).and_return(false) }
          it { expect(Spree::PaymentMethod).to receive(:available_on_back_end).and_return(payment_methods) }
        end

        context "assigns" do
          before { do_new }
          it { expect(assigns(:payment_method)).to eq check_payment_method }
        end
      end
    end

    describe "#available_payment_methods" do
      context "when subscriptions are present" do
        before do
          allow(subscriptions).to receive(:any?).and_return(true)
          allow(Spree::Gateway).to receive(:available_on_back_end).and_return(payment_methods_without_check)
        end

        context "expects to receive" do
          after { do_new }
          it { expect(Spree::Order).to receive(:find_by!).and_return(order) }
          it { expect(order).to receive(:subscriptions).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:any?).and_return(true) }
          it { expect(Spree::Gateway).to receive(:available_on_back_end).and_return(payment_methods_without_check) }
        end

        context "returns" do
          before { do_new }
          it { expect(controller.send :available_payment_methods).to eq payment_methods_without_check }
          it { expect(controller.send :available_payment_methods).to_not include check_payment_method }
        end
      end

      context "when subscriptions are not present" do
        before do
          allow(subscriptions).to receive(:any?).and_return(false)
          allow(Spree::PaymentMethod).to receive(:available_on_back_end).and_return(payment_methods)
        end

        context "expects to receive" do
          after { do_new }
          it { expect(Spree::Order).to receive(:find_by!).and_return(order) }
          it { expect(order).to receive(:subscriptions).and_return(subscriptions) }
          it { expect(subscriptions).to receive(:any?).and_return(false) }
          it { expect(Spree::PaymentMethod).to receive(:available_on_back_end).and_return(payment_methods) }
        end

        context "returns" do
          before { do_new }
          it { expect(controller.send :available_payment_methods).to eq payment_methods }
          it { expect(controller.send :available_payment_methods).to include check_payment_method }
        end
      end
    end
  end

end
