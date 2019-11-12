module Spree::Api::V1::LineItemsControllerDecorator
  def self.prepended(base)
    base.line_item_options += [:subscribe, :subscription_frequency_id, :subscription_label_status_id]
  end
end

::Spree::Api::V1::LineItemsController.prepend(Spree::Api::V1::LineItemsControllerDecorator)
