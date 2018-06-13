require 'spec_helper'

RSpec.describe SubscriptionAbility do

  describe "User" do
    describe "abilities" do
      let(:user) { create(:user) }
      let(:order) { create(:completed_order_with_totals) }
      let(:subscription) { create(:valid_subscription, enabled: true, parent_order: order, next_occurrence_at: Time.current) }

      subject(:ability) { SubscriptionAbility.new(user) }

      context 'when user is admin' do
        let(:user) { create(:admin_user) }

        it { is_expected.to be_able_to(:manage, subscription) }
      end

      context 'when subscription belongs to user' do
        let(:order) { create(:completed_order_with_totals, user_id: user.id) }

        it { is_expected.to be_able_to(:create, subscription) }
        it { is_expected.to be_able_to(:read, subscription) }
        it { is_expected.to be_able_to(:update, subscription) }
      end

      context 'when subscription does not belongs to user' do
        let(:second_user) { create(:user) }
        let(:order) { create(:completed_order_with_totals, user_id: second_user.id) }

        it { is_expected.to be_able_to(:create, subscription) }
        it { is_expected.not_to be_able_to(:read, subscription) }
        it { is_expected.not_to be_able_to(:update, subscription) }
      end

    end
  end
end
