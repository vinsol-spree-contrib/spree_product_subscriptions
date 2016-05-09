require "spec_helper"

describe Spree::PresenterHelper do

  let(:active_subscription) { create(:valid_subscription, enabled: true, delivery_number: 2) }

  context "#presenter" do
    it { expect(active_subscription.send :presenter).to be_a Spree::SubscriptionPresenter }
  end

end