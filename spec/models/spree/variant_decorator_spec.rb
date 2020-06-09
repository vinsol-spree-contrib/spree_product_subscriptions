require "spec_helper"

describe Spree::Variant, type: :model do

  describe "associations" do
    it { is_expected.to have_many(:subscriptions).class_name("Spree::Subscription").dependent(:restrict_with_error) }
  end

  describe 'delegation' do
    it { is_expected.to delegate_method(:variants_including_master).to(:product).with_prefix(true) }
  end

  describe 'alias method' do
    it { expect(Spree::Variant.instance_method(:product_variants).original_name).to eq(:product_variants_including_master) }
  end

end
