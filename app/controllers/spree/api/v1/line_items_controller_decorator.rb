Spree::Api::V1::LineItemsController.class_eval do

  self.line_item_options += [:subscribe, :subscription_frequency_id, :subscription_label_status_id]

end
