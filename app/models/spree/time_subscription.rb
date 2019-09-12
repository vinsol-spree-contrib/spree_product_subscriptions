module Spree
  class TimeSubscription < Spree::Subscription

    scope :with_appropriate_delivery_time, -> { where("next_occurrence_at <= :current_date", current_date: Time.current) }
    scope :eligible_for_subscription, -> { processable.with_appropriate_delivery_time }

    validate :next_occurrence_at_range, if: :next_occurrence_at

    with_options presence: true do
      validates :frequency
      validates :next_occurrence_at, if: :enabled?
    end

    define_model_callbacks :unpause, only: [:before]
    before_unpause :can_unpause?, :set_next_occurrence_at_after_unpause
    define_model_callbacks :process, only: [:after]
    after_process :notify_reoccurrence, if: :reoccurrence_notifiable?

    before_validation :set_next_occurrence_at, if: :can_set_next_occurrence_at?
    before_update :next_occurrence_at_not_changed?, if: :paused?

    def process
      new_order = recreate_order
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

      def reoccurrence_notifiable?
        next_occurrence_at_changed? && !!next_occurrence_at_was
      end

      def next_occurrence_at_not_changed?
        !next_occurrence_at_changed?
      end

      def next_occurrence_at_range
        unless next_occurrence_at >= Time.current.to_date
          errors.add(:next_occurrence_at, Spree.t('subscriptions.error.out_of_range'))
        end
      end

  end
end
