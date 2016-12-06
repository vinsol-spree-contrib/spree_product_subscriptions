require "spec_helper"

RSpec.describe Spree::SubscriptionFrequency, type: :model do

  describe "associations" do
    it { is_expected.to have_many(:product_subscription_frequencies).class_name("Spree::ProductSubscriptionFrequency").dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:unit) }
    it { is_expected.to define_enum_for(:unit).with(weeks: 1, months: 2) }
    it { is_expected.to validate_presence_of(:units_count) }
    it { is_expected.to validate_numericality_of(:units_count).is_greater_than(0).only_integer }
    context "uniqueness of title" do
      let!(:subscription_frequency_1) { create(:monthly_subscription_frequency) }
      let(:subscription_frequency_2) { build(:monthly_subscription_frequency) }
      before { subscription_frequency_2.save }
      it { expect(subscription_frequency_2.errors[:title]).to include I18n.t "errors.messages.taken" }
    end
  end

  describe "methods" do
    describe "#next_occurrence_from" do
      it "increments in weeks when weekly" do
        frequency = create(:weekly_subscription_frequency, title: 'weekly1')
        reference_point = Time.current
        expected = reference_point + 1.weeks
        expect(frequency.next_occurrence_from(reference_point)).to eq expected
      end

      it "increments in months when monthly" do
        frequency = create(:monthly_subscription_frequency, title: 'monthly1')
        reference_point = Time.current
        expected = reference_point + 1.months
        expect(frequency.next_occurrence_from(reference_point)).to eq expected
      end
    end
  end

end
