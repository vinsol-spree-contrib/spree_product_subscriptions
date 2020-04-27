module Spree
  module Subscriptions
    class Period < ::Spree::Subscription

      scope :with_appropriate_delivery_time, -> { where("next_occurrence_at <= :current_date", current_date: Time.current) }
      scope :eligible_for_subscription, -> { processable.with_appropriate_delivery_time }

      validate :next_occurrence_at_range, if: :next_occurrence_at

      with_options presence: true do
        validates :frequency, :prior_notification_days_gap
        validates :next_occurrence_at, if: :enabled?
      end

      validate :prior_notification_days_gap_value, if: :prior_notification_days_gap

      before_unpause :set_next_occurrence_at_after_unpause

      before_validation :set_next_occurrence_at, if: :can_set_next_occurrence_at?
      before_update :next_occurrence_at_not_changed?, if: :paused?
      after_update :update_next_occurrence_at

      def process
        if (variant.stock_items.sum(:count_on_hand) >= quantity || variant.stock_items.any? { |stock| stock.backorderable? }) && (!variant.product.discontinued?)
          update_column(:next_occurrence_possible, true)
        else
          update_column(:next_occurrence_possible, false)
        end
        new_order = recreate_order if next_occurrence_possible
        update(next_occurrence_at: next_occurrence_at_value) if new_order.try :completed?
      end

      def send_prior_notification
        if eligible_for_prior_notification?
          SubscriptionNotifier.notify_for_next_delivery(self).deliver_later
        end
      end

      private

        def eligible_for_prior_notification?
          (next_occurrence_at.to_date - Time.current.to_date).round == prior_notification_days_gap
        end

        def set_next_occurrence_at
          self.next_occurrence_at = next_occurrence_at_value
        end

        def next_occurrence_at_value
          Time.current + frequency.months_count.month
        end

        def can_set_next_occurrence_at?
          enabled? && next_occurrence_at.nil?
        end

        def set_next_occurrence_at_after_unpause
          self.next_occurrence_at = (Time.current > next_occurrence_at) ? next_occurrence_at + frequency.months_count.month : next_occurrence_at
        end

        def next_occurrence_at_not_changed?
          !next_occurrence_at_changed?
        end

        def next_occurrence_at_range
          unless next_occurrence_at >= Time.current.to_date
            errors.add(:next_occurrence_at, Spree.t('subscriptions.error.out_of_range'))
          end
        end

        def prior_notification_days_gap_value
          return if next_occurrence_at_value.nil?

          if Time.current + prior_notification_days_gap.days >= next_occurrence_at_value
            errors.add(:prior_notification_days_gap, Spree.t('subscriptions.error.should_be_earlier_than_next_delivery'))
          end
        end

        def update_next_occurrence_at
          update_column(:next_occurrence_at, next_occurrence_at_value)
        end
    end
  end
end
