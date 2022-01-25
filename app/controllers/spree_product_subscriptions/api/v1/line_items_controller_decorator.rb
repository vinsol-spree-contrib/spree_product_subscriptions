module SpreeProductSubscriptions
  module Api
    module V1
      module LineItemsControllerDecorator
        def self.prepended(base)
          base.line_item_options += [:subscribe, :subscription_frequency_id, :subscription_label_status_id]
        end
      end
    end
  end
end

::Spree::Api::V1::LineItemsController.prepend(::SpreeProductSubscriptions::Api::V1::LineItemsControllerDecorator)
