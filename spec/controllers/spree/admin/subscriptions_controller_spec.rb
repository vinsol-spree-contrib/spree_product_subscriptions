require 'spec_helper'

describe Spree::Admin::SubscriptionsController, type: :controller do

  stub_authorization!

  let(:active_subscription) { mock_model(Spree::Subscription, id: 1, enabled: true, next_occurrence_at: Time.current) }
  let(:cancelled_subscription) { mock_model(Spree::Subscription, id: 2, cancelled_at: Time.current, cancellation_reasons: "Test") }

  describe "#cancellation" do
    def do_cancellation params
      get :cancellation, params: params
    end

    let(:params) { { id: active_subscription.id } }

    before do
      allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
      allow(active_subscription).to receive(:cancelled?).and_return(false)
    end

    context "expects to receive" do
      after { do_cancellation params }
      it { expect(Spree::Subscription).to receive(:find).with(params[:id].to_s).and_return(active_subscription) }
      it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
    end

    context "response" do
      before { do_cancellation params }
      it { expect(response).to have_http_status 200 }
      it { expect(response).to render_template :cancellation }
    end
  end

  describe "pause" do
    def do_pause
      post :pause, params: { format: :json, id: active_subscription.id }
    end

    before do
      allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
      allow(active_subscription).to receive(:cancelled?).and_return(false)
    end

    describe "when pause returns success" do
      before do
        allow(active_subscription).to receive(:pause).and_return(true)
      end

      describe "expects to receive" do
        after { do_pause }
        it { expect(Spree::Subscription).to receive(:find).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
        it { expect(active_subscription).to receive(:pause).and_return(true) }
      end

      describe "response" do
        before { do_pause }
        it { expect(response).to have_http_status 200 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("admin.subscriptions.pause.success") }
      end
    end

    describe "when pause is not successful" do
      before do
        allow(active_subscription).to receive(:pause).and_return(false)
      end

      describe "expects to receive" do
        after { do_pause }
        it { expect(Spree::Subscription).to receive(:find).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
        it { expect(active_subscription).to receive(:pause).and_return(false) }
      end

      describe "response" do
        before { do_pause }
        it { expect(response).to have_http_status 422 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("admin.subscriptions.pause.error") }
      end
    end
  end

  describe "unpause" do
    def do_unpause
      post :unpause, params: { format: :json, id: active_subscription.id }
    end

    before do
      allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
      allow(active_subscription).to receive(:cancelled?).and_return(false)
    end

    describe "when unpause returns success" do
      before do
        allow(active_subscription).to receive(:unpause).and_return(true)
      end

      describe "expects to receive" do
        after { do_unpause }
        it { expect(Spree::Subscription).to receive(:find).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
        it { expect(active_subscription).to receive(:unpause).and_return(true) }
      end

      describe "response" do
        before { do_unpause }
        it { expect(response).to have_http_status 200 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("admin.subscriptions.unpause.success", next_occurrence_at: active_subscription.next_occurrence_at.to_date.to_formatted_s(:rfc822)) }
      end
    end

    describe "when unpause is not successful" do
      before do
        allow(active_subscription).to receive(:unpause).and_return(false)
      end

      describe "expects to receive" do
        after { do_unpause }
        it { expect(Spree::Subscription).to receive(:find).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
        it { expect(active_subscription).to receive(:unpause).and_return(false) }
      end

      describe "response" do
        before { do_unpause }
        it { expect(response).to have_http_status 422 }
        it { expect(JSON.parse(response.body)["flash"]).to eq Spree.t("admin.subscriptions.unpause.error") }
      end
    end
  end

  def do_cancel params
    post :cancel, params: params
  end

  describe "#Cancel" do
    context "when cancel_with_reason returns true" do

      let(:params) { { id: active_subscription.id, subscription: { cancellation_reasons: "Test" } } }

      before do
        allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
        allow(controller).to receive(:cancel_subscription_attributes).and_return(params[:subscription])
        allow(active_subscription).to receive(:cancel_with_reason).and_return(true)
        allow(active_subscription).to receive(:cancelled?).and_return(false)
      end

      context "expects to receive" do
        after { do_cancel params }
        it { expect(Spree::Subscription).to receive(:find).with(params[:id].to_s).and_return(active_subscription) }
        it { expect(controller).to receive(:cancel_subscription_attributes).and_call_original }
        it { expect(active_subscription).to receive(:cancel_with_reason).with(controller.send :cancel_subscription_attributes).and_return(true) }
        it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
      end

      context "response" do
        before { do_cancel params }
        it { expect(response).to have_http_status 302 }
        it { expect(response).to redirect_to controller.send :collection_url }
        it { expect(flash[:success]).to eq I18n.t("spree.admin.subscriptions.cancel.success") }
      end
    end

    context "when cancel_with_reason returns false" do

      let(:params) { { id: active_subscription.id, subscription: { cancellation_reasons: nil } } }

      before do
        allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
        allow(active_subscription).to receive(:cancelled?).and_return(false)
        allow(controller).to receive(:cancel_subscription_attributes).and_return(params[:subscription])
        allow(active_subscription).to receive(:cancel_with_reason).and_return(false)
      end

      context "expects to receive" do
        after { do_cancel params }
        it { expect(Spree::Subscription).to receive(:find).with(params[:id].to_s).and_return(active_subscription) }
        it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
        it { expect(controller).to receive(:cancel_subscription_attributes).and_call_original }
        it { expect(active_subscription).to receive(:cancel_with_reason).with(controller.send :cancel_subscription_attributes).and_return(false) }
      end

      context "response" do
        before { do_cancel params }
        it { expect(response).to have_http_status 200 }
        it { expect(response).to render_template :cancellation }
      end
    end
  end

  describe "callbacks" do
    describe "#ensure_not_cancelled" do
      def do_cancellation params
        get :cancellation, params: params
      end

      context "when subscription is cancelled" do

        let(:params) { { id: cancelled_subscription.id } }

        before do
          allow(Spree::Subscription).to receive(:find).and_return(cancelled_subscription)
          allow(cancelled_subscription).to receive(:cancelled?).and_return(true)
        end

        context "expects to receive" do
          after { do_cancellation params }
          it { expect(Spree::Subscription).to receive(:find).with(params[:id].to_s).and_return(cancelled_subscription) }
          it { expect(cancelled_subscription).to receive(:cancelled?).and_return(true) }
        end

        context "response" do
          before { do_cancellation params }
          it { expect(response).to have_http_status 302 }
          it { expect(response).to redirect_to controller.send :collection_url }
          it { expect(flash[:error]).to eq I18n.t("spree.admin.subscriptions.error_on_already_cancelled") }
        end
      end

      context "when subscription is not cancelled" do
        let(:params) { { id: active_subscription.id } }

        before do
          allow(Spree::Subscription).to receive(:find).and_return(active_subscription)
          allow(active_subscription).to receive(:cancelled?).and_return(false)
        end

        context "expects to receive" do
          after { do_cancellation params }
          it { expect(Spree::Subscription).to receive(:find).with(params[:id].to_s).and_return(active_subscription) }
          it { expect(active_subscription).to receive(:cancelled?).and_return(false) }
        end

        context "response" do
          before { do_cancellation params }
          it { expect(response).to have_http_status 200 }
          it { expect(response).to render_template :cancellation }
        end
      end
    end

    describe "#collection" do
      def do_index
        get :index
      end

      let(:subscriptions) { double(ActiveRecord::Relation) }
      let(:search_subscriptions) { double(Ransack::Search) }
      let(:result_subscriptions) { double(ActiveRecord::Relation) }

      before do
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:ransack).and_return(search_subscriptions)
        allow(search_subscriptions).to receive(:result).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:includes).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:references).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:order).and_return(result_subscriptions)
        allow(result_subscriptions).to receive(:page).and_return(result_subscriptions)
      end

      context "expects to receive" do
        after { do_index }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:ransack).with(controller.params[:q]).and_return(search_subscriptions) }
        it { expect(search_subscriptions).to receive(:result).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:includes).with(:frequency, :complete_orders, variant: :product).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:references).with(:complete_orders).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:order).with(created_at: :desc).and_return(result_subscriptions) }
        it { expect(result_subscriptions).to receive(:page).with(controller.params[:page]).and_return(result_subscriptions) }
      end

      context "assigns" do
        before { do_index }
        it { expect(assigns(:search)).to eq search_subscriptions }
        it { expect(assigns(:collection)).to eq result_subscriptions }
      end
    end
  end

end
