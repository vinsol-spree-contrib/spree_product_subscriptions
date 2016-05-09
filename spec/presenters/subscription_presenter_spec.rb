require "spec_helper"

describe Spree::SubscriptionPresenter do

  let(:active_subscription) { create(:valid_subscription, enabled: true, delivery_number: 2) }
  let(:presenter) { active_subscription.presenter }

  context "#initialize" do
    it { expect(presenter.send(:initialize, active_subscription)).to eq active_subscription }
  end

	context "#delivery_count" do
    context "if delivery_number is present" do
      it { expect(presenter.send :delivery_count).to eq active_subscription.delivery_number }
    end
    context "if delivery_number is not present" do
      before { active_subscription.delivery_number = nil }
      it { expect(presenter.send :delivery_count).to eq Float::INFINITY }
    end
  end

end