require "spec_helper"

describe Spree::OrdersController, type: :controller do

  stub_authorization!

  describe "Callbacks" do
    describe "#add_subscription_fields" do
      def do_populate params
        spree_post :populate, params
      end

      let(:variant) { create(:variant) }
      let (:with_subscribe_params) { { subscribe: true, variant_id: variant.id, subscription: { subscription_frequency_id: 1, delivery_number: 6 } }.with_indifferent_access }

      context "send populate request with params[:subscribe] present" do
        before { do_populate with_subscribe_params }
        it { expect(controller.send :add_subscription_fields).to_not be_nil }
      end
    end
  end

  describe "Callbacks" do
    describe "#restrict_guest_subscription" do
      def do_update params
        spree_put :update, params
      end

      let (:order) { mock_model(Spree::Order) }
      let (:order_subscriptions) { double(Spree::OrderSubscription) }
      let (:with_order_params) { { "order" => { "line_items_attributes" => { "0" => { "quantity"=>"1", "subscription_frequency_id"=>"3", "id"=>"9" } } }.with_indifferent_access } }

      before do
        allow(controller).to receive(:current_order).and_return(order)
        allow(order).to receive(:subscriptions).and_return(order_subscriptions)
      end

      context "send update request with params[:order] present" do
        it { expect(controller).to receive(:current_order).and_return(order_subscriptions) }
        it { expect(order).to receive(:subscriptions).and_return(order) }
        it { expect(order_subscriptions).to receive(:present?).and_return(true) }

        after { do_update with_order_params }
      end

      context 'response' do
        before { do_update with_order_params }

        it { is_expected.to respond_with 302 }
        it { expect(response).to redirect_to(login_path) }
      end
    end
  end

end
