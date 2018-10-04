module Spree
  class Subscription < Spree::Base

    attr_accessor :cancelled

    include Spree::Core::NumberGenerator.new(prefix: 'S')

    ACTION_REPRESENTATIONS = {
                               pause: "Pause",
                               unpause: "Activate",
                               cancel: "Cancel"
                             }

    USER_DEFAULT_CANCELLATION_REASON = "Cancelled By User"

    belongs_to :ship_address, class_name: "Spree::Address"
    belongs_to :bill_address, class_name: "Spree::Address"
    belongs_to :parent_order, class_name: "Spree::Order"
    belongs_to :variant, inverse_of: :subscriptions
    belongs_to :frequency, foreign_key: :subscription_frequency_id, class_name: "Spree::SubscriptionFrequency"
    belongs_to :source, polymorphic: true

    accepts_nested_attributes_for :ship_address, :bill_address

    has_many :orders_subscriptions, class_name: "Spree::OrderSubscription", dependent: :destroy
    has_many :orders, through: :orders_subscriptions
    has_many :complete_orders, -> { complete }, through: :orders_subscriptions, source: :order

    self.whitelisted_ransackable_associations = %w( parent_order )

    scope :paused, -> { where(paused: true) }
    scope :unpaused, -> { where(paused: false) }
    scope :disabled, -> { where(enabled: false) }
    scope :active, -> { where(enabled: true) }
    scope :not_cancelled, -> { where(cancelled_at: nil) }
    scope :with_appropriate_delivery_time, -> { where("next_occurrence_at <= :current_date", current_date: Time.current) }
    scope :processable, -> { unpaused.active.not_cancelled }
    scope :eligible_for_subscription, -> { processable.with_appropriate_delivery_time }
    scope :with_parent_orders, -> (orders) { where(parent_order: orders) }

    with_options allow_blank: true do
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :quantity, numericality: { greater_than: 0, only_integer: true }
      validates :delivery_number, numericality: { greater_than_or_equal_to: :recurring_orders_size, only_integer: true }
    end
    with_options presence: true do
      validates :quantity, :delivery_number, :price, :number, :parent_order, :frequency
      validates :cancellation_reasons, :cancelled_at, if: :cancelled
      validates :ship_address, :bill_address, :next_occurrence_at, :source, if: :enabled?
    end
    validate :next_occurrence_at_range, if: :next_occurrence_at

    define_model_callbacks :pause, only: [:before]
    before_pause :can_pause?
    define_model_callbacks :unpause, only: [:before]
    before_unpause :can_unpause?, :set_next_occurrence_at_after_unpause
    define_model_callbacks :process, only: [:after]
    after_process :notify_reoccurrence, if: :reoccurrence_notifiable?
    define_model_callbacks :cancel, only: [:before]
    before_cancel :set_cancellation_reason, if: :can_set_cancellation_reason?

    before_validation :set_next_occurrence_at, if: :can_set_next_occurrence_at?
    before_validation :set_cancelled_at, if: :can_set_cancelled_at?
    before_update :not_cancelled?
    before_validation :update_price, on: :update, if: :variant_id_changed?
    before_update :next_occurrence_at_not_changed?, if: :paused?
    after_update :notify_user, if: :user_notifiable?
    after_update :notify_cancellation, if: :cancellation_notifiable?

    def process
      new_order = recreate_order if deliveries_remaining?
      update(next_occurrence_at: next_occurrence_at_value) if new_order.try :completed?
    end

    def cancel_with_reason(attributes)
      self.cancelled = true
      update(attributes)
    end

    def cancelled?
      !!cancelled_at_was
    end

    def number_of_deliveries_left
      delivery_number.to_i - complete_orders.size - 1
    end

    def pause
      run_callbacks :pause do
        update_attributes(paused: true)
      end
    end

    def unpause
      run_callbacks :unpause do
        update_attributes(paused: false)
      end
    end

    def cancel
      self.cancelled = true
      run_callbacks :cancel do
        update_attributes(cancelled_at: Time.current)
      end
    end

    def deliveries_remaining?
      number_of_deliveries_left > 0
    end

    def not_changeable?
      cancelled? || !deliveries_remaining?
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

      def update_price
        if valid_variant?
          self.price = variant.price
        else
          self.errors.add(:variant_id, :does_not_belong_to_product)
        end
      end

      def valid_variant?
        variant_was = Spree::Variant.find_by(id: variant_id_was)
        variant.present? && variant_was.try(:product_id) == variant.product_id
      end

      def set_cancelled_at
        self.cancelled_at = Time.current
      end

      def set_next_occurrence_at
        self.next_occurrence_at = next_occurrence_at_value
      end

      def next_occurrence_at_value
        deliveries_remaining? ? Time.current + frequency.months_count.month : next_occurrence_at
      end

      def can_set_next_occurrence_at?
        enabled? && next_occurrence_at.nil? && deliveries_remaining?
      end

      def set_next_occurrence_at_after_unpause
        self.next_occurrence_at = (Time.current > next_occurrence_at) ? next_occurrence_at + frequency.months_count.month : next_occurrence_at
      end

      def can_pause?
        enabled? && !cancelled? && deliveries_remaining? && !paused?
      end

      def can_unpause?
        enabled? && !cancelled? && deliveries_remaining? && paused?
      end

      def recreate_order
        order = make_new_order
        add_variant_to_order(order)
        add_shipping_address(order)
        add_delivery_method_to_order(order)
        add_payment_method_to_order(order)
        confirm_order(order)
        order
      end

      def make_new_order
        orders.create(order_attributes)
      end

      def add_variant_to_order(order)
        variant = Spree::Variant.random_variant
        order.contents.add(variant, quantity)
        order.next
      end

      def add_shipping_address(order)
        order.ship_address = ship_address.clone
        order.bill_address = bill_address.clone
        order.next
      end

      def add_delivery_method_to_order(order)
        order.next
      end

      def add_payment_method_to_order(order)
        if order.payments.exists?
          order.payments.first.update(source: source, payment_method: source.payment_method)
        else
          order.payments.create(source: source, payment_method: source.payment_method, amount: order.total)
        end
        order.next
      end

      def confirm_order(order)
        order.next
      end

      def order_attributes
        {
          email: parent_order.email,
          currency: parent_order.currency,
          guest_token: parent_order.guest_token,
          store: parent_order.store,
          user: parent_order.user,
          created_by: parent_order.user,
          last_ip_address: parent_order.last_ip_address
        }
      end

      def notify_user
        SubscriptionNotifier.notify_confirmation(self).deliver_later
      end

      def not_cancelled?
        !cancelled?
      end

      def can_set_cancelled_at?
        cancelled.present? && deliveries_remaining?
      end

      def set_cancellation_reason
        self.cancellation_reasons = USER_DEFAULT_CANCELLATION_REASON
      end

      def can_set_cancellation_reason?
        cancelled.present? && deliveries_remaining? && cancellation_reasons.nil?
      end

      def notify_cancellation
        SubscriptionNotifier.notify_cancellation(self).deliver_later
      end

      def cancellation_notifiable?
        cancelled_at.present? && cancelled_at_changed?
      end

      def reoccurrence_notifiable?
        next_occurrence_at_changed? && !!next_occurrence_at_was
      end

      def notify_reoccurrence
        SubscriptionNotifier.notify_reoccurrence(self).deliver_later
      end

      def recurring_orders_size
        complete_orders.size + 1
      end

      def user_notifiable?
        enabled? && enabled_changed?
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
