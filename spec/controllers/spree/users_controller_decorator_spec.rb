require "spec_helper"

describe Spree::UsersController, type: :controller do

  stub_authorization!

  describe "Callbacks" do
    describe "#load_subscriptions" do
      def do_show
        get :show
      end

      let(:orders) { double(ActiveRecord::Relation) }
      let(:subscriptions) { double(ActiveRecord::Relation) }
      let(:user) { mock_model(Spree.user_class) }

      before do
        allow(controller).to receive(:spree_current_user).and_return(user)
        allow(user).to receive(:orders).and_return(orders)
        allow(orders).to receive(:complete).and_return(orders)
        allow(orders).to receive(:order).and_return(orders)
        allow(Spree::Subscription).to receive(:active).and_return(subscriptions)
        allow(subscriptions).to receive(:order).and_return(subscriptions)
        allow(subscriptions).to receive(:with_parent_orders).and_return(subscriptions)
      end

      context "expects to receive" do
        after { do_show }
        it { expect(controller).to receive(:spree_current_user).and_return(user) }
        it { expect(user).to receive(:orders).and_return(orders) }
        it { expect(orders).to receive(:complete).and_return(orders) }
        it { expect(orders).to receive(:order).with(completed_at: :desc).and_return(orders) }
        it { expect(Spree::Subscription).to receive(:active).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:order).with(created_at: :desc).and_return(subscriptions) }
        it { expect(subscriptions).to receive(:with_parent_orders).with(orders).and_return(subscriptions) }
      end

      context "assigns" do
        before { do_show }
        it { expect(assigns(:orders)).to eq orders }
        it { expect(assigns(:subscriptions)).to eq subscriptions }
      end
    end
  end

end
