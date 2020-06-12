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
    belongs_to :source, polymorphic: true
    belongs_to :frequency, foreign_key: :subscription_frequency_id, class_name: "Spree::SubscriptionFrequency"
    belongs_to :label_status, foreign_key: :subscription_label_status_id, class_name: "Spree::SubscriptionLabelStatus"

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
    scope :processable, -> { unpaused.active.not_cancelled }
    scope :with_parent_orders, -> (orders) { where(parent_order: orders) }

    with_options allow_blank: true do
      validates :price, numericality: { greater_than_or_equal_to: 0 }
      validates :quantity, numericality: { greater_than: 0, only_integer: true }
      validates :parent_order, uniqueness: { scope: :variant }
    end
    with_options presence: true do
      validates :quantity, :price, :number, :variant, :parent_order
      validates :cancellation_reasons, :cancelled_at, if: :cancelled
      validates :ship_address, :bill_address, :source, if: :enabled?
    end

    define_model_callbacks :pause, only: [:before]
    before_pause :can_pause?
    define_model_callbacks :unpause, only: [:before]
    before_unpause :can_unpause?
    define_model_callbacks :process, only: [:after]
    after_process :notify_reoccurrence

    define_model_callbacks :cancel, only: [:before]
    before_cancel :set_cancellation_reason, if: :can_set_cancellation_reason?

    before_create :set_type
    before_validation :set_cancelled_at, if: :can_set_cancelled_at?
    before_update :not_cancelled?
    before_validation :update_price, on: :update, if: :variant_id_changed?
    after_update :notify_user, if: :user_notifiable?
    after_update :notify_cancellation, if: :cancellation_notifiable?

    def cancel_with_reason(attributes)
      self.cancelled = true
      update(attributes)
    end

    def cancelled?
      !!cancelled_at_was
    end

    def pause
      run_callbacks :pause do
        update(paused: true)
      end
    end

    def unpause
      run_callbacks :unpause do
        update(paused: false)
      end
    end

    def cancel
      self.cancelled = true
      run_callbacks :cancel do
        update(cancelled_at: Time.current)
      end
    end

    def not_changeable?
      cancelled?
    end

    private

      def set_type
        self.sub_type = subscription_frequency_id ? 'Spree::Subscriptions::Period' : 'Spree::Subscriptions::LabelStatus'
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

      def can_pause?
        enabled? && !cancelled? && !paused?
      end

      def can_unpause?
        enabled? && !cancelled? && paused?
      end

      def recreate_order
        order = make_new_order
        add_variant_to_order(order)
        add_shipping_address(order)
        add_delivery_method_to_order(order)
        add_shipping_costs_to_order(order)
        add_payment_method_to_order(order)
        confirm_order(order)
        order
      end

      def make_new_order
        orders.create(order_attributes)
      end

      def add_variant_to_order(order)
        Spree::Dependencies.cart_add_item_service.constantize.call(
          order: order,
          variant: variant,
          quantity: 1
        )
        order.next
      end

      def add_shipping_address(order)
        order.ship_address = ship_address.clone
        order.bill_address = bill_address.clone
        order.next
      end

      # select shipping method which was selected in original order.
      def add_delivery_method_to_order(order)
        selected_shipping_method_id = parent_order.inventory_units.where(variant_id: variant.id).first.shipment.shipping_method.id

        order.shipments.each do |shipment|
          current_shipping_rate = shipment.shipping_rates.find_by(selected: true)
          proposed_shipping_rate = shipment.shipping_rates.find_by(shipping_method_id: selected_shipping_method_id)

          if proposed_shipping_rate.present? && current_shipping_rate != proposed_shipping_rate
            current_shipping_rate.update(selected: false)
            proposed_shipping_rate.update(selected: true)
          end
        end

        order.next
      end

      def add_shipping_costs_to_order(order)
        order.set_shipments_cost
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
          currency: parent_order.currency,
          token: parent_order.token,
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
        cancelled.present?
      end

      def set_cancellation_reason
        self.cancellation_reasons = USER_DEFAULT_CANCELLATION_REASON
      end

      def can_set_cancellation_reason?
        cancelled.present? && cancellation_reasons.nil?
      end

      def notify_cancellation
        SubscriptionNotifier.notify_cancellation(self).deliver_later
      end

      def cancellation_notifiable?
        cancelled_at.present? && cancelled_at_changed?
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
  end
end
