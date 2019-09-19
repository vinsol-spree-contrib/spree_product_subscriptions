module Spree
  class LabelStatusSubscription < Spree::Subscription
    alias_attribute :frequency, :label_status

    scope :has_orders, -> { joins(:orders) }
    scope :no_suborders, -> {
      joins('LEFT OUTER JOIN "spree_orders_subscriptions" ON "spree_orders_subscriptions"."subscription_id" = "spree_subscriptions"."id"')
      .where('spree_orders_subscriptions.subscription_id IS NULL')
    }

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

    def send_prior_notification
      if eligible_for_prior_notification?
        SubscriptionNotifier.notify_for_next_delivery(self).deliver_later
      end
    end

    private
      def order_status_correct?(order)
        order.all_shipments_has_label? && order.all_shipments_label_status_is?(label_status.label_status)
      end

      def eligible_for_prior_notification?
        (next_occurrence_at.to_date - Time.current.to_date).round == prior_notification_days_gap
      end

      def reoccurrence_notifiable?
        next_occurrence_at_changed? && !!next_occurrence_at_was
      end
  end
end
