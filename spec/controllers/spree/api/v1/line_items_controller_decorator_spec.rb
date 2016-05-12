require "spec_helper"

describe Spree::Api::V1::LineItemsController, type: :controller do

  describe "line_item_options" do
    it { expect(Spree::Api::V1::LineItemsController.line_item_options).to include :subscription_frequency_id }
    it { expect(Spree::Api::V1::LineItemsController.line_item_options).to include :delivery_number }
    it { expect(Spree::Api::V1::LineItemsController.line_item_options).to include :subscribe }
  end

end
