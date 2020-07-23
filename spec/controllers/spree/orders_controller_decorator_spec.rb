require "spec_helper"

describe Spree::OrdersController, type: :controller do

  stub_authorization!

  describe "Callbacks" do
    describe "#restrict_guest_subscription" do
      def do_update params
        put :update, params: params
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
