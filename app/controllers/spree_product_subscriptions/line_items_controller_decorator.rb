module SpreeProductSubscriptions::LineItemsControllerDecorator

  def self.prepended(base)
    base.line_item_options += [:subscribe, :delivery_number, :subscription_frequency_id]
  end


end

Spree::Api::V1::LineItemsController.prepend SpreeProductSubscriptions::LineItemsControllerDecorator