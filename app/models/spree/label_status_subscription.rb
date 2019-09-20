module Spree
  class LabelStatusSubscription < Spree::Subscription
    alias_attribute :frequency, :label_status

    with_options presence: true do
      validates :label_status
    end

    def process
      new_order = recreate_order if deliveries_remaining?
    end

    def can_be_proccesed?
      previous_order = orders.any? ? orders.last : parent_order
      order_status_correct?(previous_order)
    end

    private
      def order_status_correct?(order)
        order.all_shipments_has_label? && order.all_shipments_label_status_is?(label_status.label_status)
      end
  end
end
