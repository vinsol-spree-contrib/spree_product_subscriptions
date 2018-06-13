require "spec_helper"

describe Spree::Subscription, type: :model do

  let(:last_ip_address) { "127.0.0.1" }
  let(:order) { create(:completed_order_with_totals, last_ip_address: last_ip_address) }
  let(:orders) { [create(:completed_order_with_totals)] }
  let(:nil_attributes_subscription) { build(:nil_attributes_subscription) }
  let(:active_subscription) { create(:valid_subscription, enabled: true, parent_order: order, next_occurrence_at: just_passed_time) }
  let(:disabled_subscription) { create(:valid_subscription, enabled: false) }
  let(:completed_subscription) { create(:valid_subscription, enabled: true, delivery_number: 1, next_occurrence_at: Time.current + 10.days) }
  let(:paused_subscription) { create(:valid_subscription, paused: true, enabled: true, next_occurrence_at: just_passed_time) }
  let(:cancelled_subscription) { create(:valid_subscription, cancelled_at: Time.current, cancellation_reasons: "Test") }
  let(:subscription_with_recreated_orders) { create(:valid_subscription, orders: orders, next_occurrence_at: just_passed_time) }
  let(:just_passed_time) { Time.current - 1.minute }
  let(:frequency) { create(:monthly_subscription_frequency) }

  describe "validations" do
    before { subject.frequency = frequency }

    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.to validate_presence_of(:delivery_number) }
    it { is_expected.to validate_presence_of(:price) }
    context "validates presence of number" do
      context "when number is absent" do
        before { nil_attributes_subscription.save }
        it { expect(nil_attributes_subscription.number).to be_present }
      end

      context "when number is present" do
        before do
          nil_attributes_subscription.number = "S123456789"
          nil_attributes_subscription.save
        end
        it { expect(nil_attributes_subscription.number).to be_present }
      end
    end
    it { is_expected.to validate_presence_of(:variant) }
    it { is_expected.to validate_presence_of(:parent_order) }
    it { is_expected.to validate_presence_of(:frequency) }
    it { is_expected.to validate_presence_of(:prior_notification_days_gap) }

    context "if cancelled present" do
      before { subject.cancelled = true }
      it { expect(subject).to validate_presence_of(:cancellation_reasons) }
      context "validate_presence_of cancelled_at" do
        context "when cancelled at is present" do
          before do
            nil_attributes_subscription.cancelled = true
            nil_attributes_subscription.cancelled_at = Time.current
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.cancelled_at).to be_present }
        end

        context "when cancelled_at is absent" do
          before do
            nil_attributes_subscription.cancelled = true
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.cancelled_at).to_not be_present }
        end
      end
    end
    context "if enabled" do
      before { subject.enabled = true }
      it { expect(subject).to validate_presence_of(:ship_address) }
      it { expect(subject).to validate_presence_of(:bill_address) }
      context "validate_presence_of next_occurrence_at" do
        context "when next_occurrence_at is present" do
          before do
            nil_attributes_subscription.enabled = true
            nil_attributes_subscription.next_occurrence_at = Time.current
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.next_occurrence_at).to be_present }
        end

        context "when next_occurrence_at is absent" do
          before do
            nil_attributes_subscription.enabled = true
            nil_attributes_subscription.save
          end
          it { expect(nil_attributes_subscription.next_occurrence_at).to_not be_present }
        end
      end
      it { expect(subject).to validate_presence_of(:source) }
    end
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0).allow_nil }
    it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0).only_integer.allow_nil }
    it { is_expected.to validate_numericality_of(:delivery_number).is_greater_than_or_equal_to(subject.send :recurring_orders_size).only_integer.allow_nil }
  end

  describe "associations" do
    it { is_expected.to belong_to(:ship_address).class_name("Spree::Address") }
    it { is_expected.to belong_to(:bill_address).class_name("Spree::Address") }
    it { is_expected.to belong_to(:parent_order).class_name("Spree::Order") }
    it { is_expected.to belong_to(:variant).inverse_of(:subscriptions) }
    it { is_expected.to belong_to(:frequency).class_name("Spree::SubscriptionFrequency").with_foreign_key(:subscription_frequency_id) }
    it { is_expected.to belong_to(:source) }
    it { is_expected.to have_many(:orders_subscriptions).class_name("Spree::OrderSubscription").dependent(:destroy) }
    it { is_expected.to have_many(:orders).through(:orders_subscriptions) }
    it { is_expected.to have_many(:complete_orders).through(:orders_subscriptions).source(:order) }
    it { is_expected.to accept_nested_attributes_for(:ship_address) }
    it { is_expected.to accept_nested_attributes_for(:bill_address) }
  end

  describe "callbacks" do
    it { is_expected.to callback(:set_next_occurrence_at).before(:validation).if(:can_set_next_occurrence_at?) }
    it { is_expected.to callback(:set_cancelled_at).before(:validation).if(:can_set_cancelled_at?) }
    it { is_expected.to callback(:update_price).before(:validation).on(:update).if(:variant_id_changed?) }
    it { is_expected.to callback(:notify_cancellation).after(:update).if(:cancellation_notifiable?) }
    it { is_expected.to callback(:not_cancelled?).before(:update) }
    it { is_expected.to callback(:next_occurrence_at_not_changed?).before(:update).if(:paused?) }
    it { is_expected.to callback(:notify_user).after(:update).if(:user_notifiable?) }
    it { is_expected.to callback(:can_pause?).before(:pause) }
    it { is_expected.to callback(:can_unpause?).before(:unpause) }
    it { is_expected.to callback(:set_next_occurrence_at_after_unpause).before(:unpause) }
    it { is_expected.to callback(:set_cancellation_reason).before(:cancel).if(:can_set_cancellation_reason?) }
    it { is_expected.to callback(:notify_reoccurrence).after(:process).if(:reoccurrence_notifiable?) }
  end

  describe "attr_accessors" do
    it { is_expected.to respond_to :cancelled }
    it { is_expected.to respond_to :cancelled= }
  end

  describe "scopes" do
    context ".disabled" do
      it { expect(Spree::Subscription.disabled).to include disabled_subscription }
      it { expect(Spree::Subscription.disabled).to_not include active_subscription }
    end

    context ".active" do
      it { expect(Spree::Subscription.active).to include active_subscription }
      it { expect(Spree::Subscription.active).to_not include disabled_subscription }
    end

    context ".not_cancelled" do
      it { expect(Spree::Subscription.not_cancelled).to include active_subscription }
      it { expect(Spree::Subscription.not_cancelled).to_not include cancelled_subscription }
    end

    context ".processable" do
      it { expect(Spree::Subscription.processable).to include active_subscription }
      it { expect(Spree::Subscription.processable).to_not include disabled_subscription }
      it { expect(Spree::Subscription.processable).to_not include cancelled_subscription }
      it { expect(Spree::Subscription.processable).to_not include paused_subscription }
    end

    context ".eligible_for_subscription" do
      it { expect(Spree::Subscription.eligible_for_subscription).to include active_subscription }
      it { expect(Spree::Subscription.eligible_for_subscription).to_not include disabled_subscription }
      it { expect(Spree::Subscription.eligible_for_subscription).to_not include cancelled_subscription }
      it { expect(Spree::Subscription.eligible_for_subscription).to_not include paused_subscription }
    end

    context ".with_parent_orders" do
      it { expect(Spree::Subscription.with_parent_orders(order)).to include active_subscription }
      it { expect(Spree::Subscription.with_parent_orders(order)).to_not include disabled_subscription }
    end

    context ".paused" do
      it { expect(Spree::Subscription.paused).to include paused_subscription }
      it { expect(Spree::Subscription.paused).to_not include active_subscription }
    end

    context ".unpaused" do
      it { expect(Spree::Subscription.unpaused).to_not include paused_subscription }
      it { expect(Spree::Subscription.unpaused).to include active_subscription }
    end

    context ".with_appropriate_delivery_time" do
      it { expect(Spree::Subscription.with_appropriate_delivery_time).to include active_subscription }
      it { expect(Spree::Subscription.with_appropriate_delivery_time).to_not include disabled_subscription }
    end
  end

  describe "ransackable" do
    context "whitelisted ransackable associations" do
      it { expect(Spree::Subscription.whitelisted_ransackable_associations).to include "parent_order" }
    end
  end

  describe "methods" do
    context "#cancelled?" do
      it { expect(active_subscription).to_not be_cancelled }
      it { expect(disabled_subscription).to_not be_cancelled }
      it { expect(cancelled_subscription).to be_cancelled }
    end

    context "#set_cancelled_at" do
      before { nil_attributes_subscription.send :set_cancelled_at }
      it { expect(nil_attributes_subscription.cancelled_at).to_not be_nil }
    end

    context "#update_price" do
      let(:subscription_variant) { create(:base_variant, product_id: 1) }
      let(:subscription_variant_with_same_product) { create(:base_variant, product_id: 1) }
      let(:subscription_variant_with_different_product) { create(:base_variant, product_id: 2) }

      before do
        active_subscription.update_column(:variant_id, subscription_variant_with_same_product.id)
        active_subscription.variant_id = subscription_variant.id
        active_subscription.send :update_price
      end
      context "when changed variant is valid" do
        it { expect(active_subscription.price).to eq active_subscription.variant.price }
      end

      context "when changed variant is not valid" do
        before do
          active_subscription.variant_id = subscription_variant_with_different_product.id
          active_subscription.send :update_price
        end
        it { expect(active_subscription.errors.present?).to eq true }
      end
    end

    context "#set_next_occurrence_at" do
      before { active_subscription.send :set_next_occurrence_at }
      it { expect(active_subscription).to be_next_occurrence_at_changed }
    end

    context "#next_occurrence_at_value" do
      context "when deliveries remaining" do
        it { expect(active_subscription.send :next_occurrence_at_value).to_not eq active_subscription.next_occurrence_at }
      end

      context "when deliveries are not remaining" do
        it { expect(completed_subscription.send :next_occurrence_at_value).to eq completed_subscription.next_occurrence_at }
      end
    end

    context "#set_cancellation_reason" do
      before { nil_attributes_subscription.send :set_cancellation_reason }
      it { expect(nil_attributes_subscription.cancellation_reasons).to eq "Cancelled By User" }
    end

    context "#can_set_cancellation_reason?" do
      context "when cancelled is not set" do
        it { expect(active_subscription.send :can_set_cancellation_reason?).to eq false }
      end

      context "when cancelled bit is set" do
        before { active_subscription.cancelled = true }
        it { expect(active_subscription.send :can_set_cancellation_reason?).to eq true }
      end

      context "if subscription is already cancelled" do
        it { expect(cancelled_subscription.send :can_set_cancellation_reason?).to eq false }
      end
    end

    context "#can_set_next_occurrence_at?" do
      context "when enabled and next_occurrence_at present" do
        it { expect(active_subscription.send :can_set_next_occurrence_at?).to eq false }
        it { expect(subscription_with_recreated_orders.send :can_set_next_occurrence_at?).to eq false }
      end

      context "when disbaled and next_occurrence_at absent" do
        it { expect(disabled_subscription.send :can_set_next_occurrence_at?).to eq false }
      end

      context "when enabled and next_occurrence_at is nil" do
        before { active_subscription.next_occurrence_at = nil }
        it { expect(active_subscription.send :can_set_next_occurrence_at?).to eq true }
      end
    end

    context "#pause" do
      before { active_subscription.pause }
      it { expect(active_subscription).to be_paused }
    end

    context "#unpause" do
      before { paused_subscription.unpause }
      it { expect(paused_subscription).to_not be_paused }
    end

    context "#cancel" do
      before { active_subscription.cancel }
      it { expect(active_subscription.cancelled_at).to_not be_nil }
      it { expect(active_subscription.cancellation_reasons).to_not be_nil }
      it { expect(active_subscription.cancellation_reasons).to eq Spree::Subscription::USER_DEFAULT_CANCELLATION_REASON }
    end

    context "#not_changeable?" do
      it { expect(active_subscription).to_not be_not_changeable }
      it { expect(paused_subscription).to_not be_not_changeable }
      it { expect(cancelled_subscription).to be_not_changeable }
      it { expect(completed_subscription).to be_not_changeable }
    end

    context "#can_pause?" do
      it { expect(active_subscription.send :can_pause?).to eq true }
      it { expect(paused_subscription.send :can_pause?).to eq false }
      it { expect(cancelled_subscription.send :can_pause?).to eq false }
      it { expect(disabled_subscription.send :can_pause?).to eq false }
      it { expect(completed_subscription.send :can_pause?).to eq false }
    end

    context "#can_unpause?" do
      it { expect(active_subscription.send :can_unpause?).to eq false }
      it { expect(paused_subscription.send :can_unpause?).to eq true }
      it { expect(cancelled_subscription.send :can_unpause?).to eq false }
      it { expect(disabled_subscription.send :can_unpause?).to eq false }
      it { expect(completed_subscription.send :can_unpause?).to eq false }
    end

    context "#next_occurrence_at_not_changed?" do
      context "when next occurrence at is changed" do
        before { active_subscription.next_occurrence_at = Time.current }
        it { expect(active_subscription.send :next_occurrence_at_not_changed?).to eq false }
      end

      context "when next occurrence at is not changed" do
        it { expect(active_subscription.send :next_occurrence_at_not_changed?).to eq true }
      end
    end

    context "#next_occurrence_at_range" do
      before do
        nil_attributes_subscription.next_occurrence_at = Time.current - 1.day
        nil_attributes_subscription.send :next_occurrence_at_range
      end
      it { expect(nil_attributes_subscription.errors[:next_occurrence_at]).to include Spree.t('subscriptions.error.out_of_range') }
    end

    describe '#next_occurrence_at_range' do
      before do
        completed_subscription.next_occurrence_at = Time.current
        completed_subscription.save
      end

      it 'is expected not the save the subscription' do
        expect(completed_subscription.valid?).to eq(false)
      end

      it 'is expected to add error message to subscription' do
        expect(completed_subscription.errors.messages[:prior_notification_days_gap]).to eq([Spree.t('subscriptions.error.should_be_earlier_than_next_delivery')])
      end
    end

    context "#not_cancelled?" do
      it { expect(active_subscription.send :not_cancelled?).to eq true }
      it { expect(disabled_subscription.send :not_cancelled?).to eq true }
      it { expect(cancelled_subscription.send :not_cancelled?).to eq false }
    end

    context "#can_set_cancelled_at?" do
      context "when cancelled present" do
        before { active_subscription.cancelled = true }
        it { expect(active_subscription.send :can_set_cancelled_at?).to eq true }
      end

      context "when cancelled not present" do
        it { expect(active_subscription.send :can_set_cancelled_at?).to eq false }
      end
    end

    context "#cancellation_notifiable?" do
      context "when cancelled at not present neither changed" do
        it { expect(active_subscription.send :cancellation_notifiable?).to eq false }
      end

      context "when cancelled at present and value changed" do
        before { active_subscription.cancelled_at = Time.current }
        it { expect(active_subscription.send :cancellation_notifiable?).to eq true }
      end
    end

    context "#reoccurrence_notifiable?" do
      context "when next_occurrence_at present and not changed" do
        it { expect(subscription_with_recreated_orders.send :reoccurrence_notifiable?).to eq false }
      end

      context "when next_occurrence_at present and got changed" do
        before { subscription_with_recreated_orders.next_occurrence_at = Time.current }
        it { expect(subscription_with_recreated_orders.send :reoccurrence_notifiable?).to eq true }
      end

      context "when next_occurrence_at not present" do
        it { expect(active_subscription.send :reoccurrence_notifiable?).to eq false }
      end
    end

    context "#deliveries_remaining?" do
      it { expect(subscription_with_recreated_orders.deliveries_remaining?).to eq true }
      it { expect(active_subscription.deliveries_remaining?).to eq true }
    end

    context "#number_of_deliveries_left" do
      let(:completed_order) { create(:completed_order_with_totals) }
      it { expect { active_subscription.complete_orders << completed_order }.to change { active_subscription.number_of_deliveries_left }.by -1 }
    end

    context "#cancellation_notifiable?" do
      context "when cancelled at present and not changed" do
        it { expect(cancelled_subscription.send :cancellation_notifiable?).to eq false }
      end

      context "when cancelled at is not present" do
        it { expect(active_subscription.send :cancellation_notifiable?).to eq false }
      end

      context "when cancelled_at present and changed" do
        before { active_subscription.cancelled_at = Time.current }
        it { expect(active_subscription.send :cancellation_notifiable?).to eq true }
      end
    end

    context "#recurring_orders_size" do
      let(:completed_order) { create(:completed_order_with_totals) }
      it { expect { active_subscription.complete_orders << completed_order }.to change { active_subscription.send :recurring_orders_size }.by 1 }
    end

    context "#user_notifiable?" do
      context "when enabled present but not changed" do
        it { expect(active_subscription.send :user_notifiable?).to eq false }
      end

      context "when enabled is not present" do
        it { expect(disabled_subscription.send :user_notifiable?).to eq false }
      end

      context "when enabled is present and is recently changed" do
        before { disabled_subscription.enabled = true }
        it { expect(disabled_subscription.send :user_notifiable?).to eq true }
      end
    end

    context "#cancel_with_reason" do
      before { active_subscription.cancel_with_reason({ cancellation_reasons: "Test" }) }
      it { expect(active_subscription.cancelled_at).to_not be_nil }
      it { expect(active_subscription.cancellation_reasons).to_not be_nil }
      it { expect(active_subscription.cancellation_reasons).to eq "Test" }
    end

    context "#order_attributes" do
      it { expect(active_subscription.send :order_attributes).to eq ({
        currency: order.currency,
        guest_token: order.guest_token,
        store: order.store,
        user: order.user,
        created_by: order.user,
        last_ip_address: last_ip_address
        }) }
    end

    context "#order recreation" do
      let(:order_attributes) { {
        currency: order.currency,
        guest_token: order.guest_token,
        store: order.store,
        user: order.user,
        created_by: order.user,
        last_ip_address: last_ip_address,
        line_items: []
        } }
      let(:new_order) { create(:order, order_attributes) }
      let(:created_order) { active_subscription.send :make_new_order }
      let(:created_order_with_variant) { active_subscription.send(:add_variant_to_order, created_order); created_order }
      let(:created_order_with_addresses) { active_subscription.send(:add_shipping_address, created_order_with_variant); created_order_with_variant }
      let(:created_order_with_delivery_method) { active_subscription.send(:add_delivery_method_to_order, created_order_with_addresses); created_order_with_addresses }
      let(:created_order_with_payment_method) { active_subscription.send(:add_payment_method_to_order, created_order_with_delivery_method); created_order_with_delivery_method }
      let(:created_order_with_confirmation) { active_subscription.send(:confirm_order, created_order_with_payment_method); created_order_with_payment_method }

      before do
        active_subscription.parent_order.inventory_units.update_all(variant_id: active_subscription.variant.id)
      end

      context "#make_new_order" do
        it { expect(created_order.currency).to eq new_order.currency }
        it { expect(created_order.guest_token).to eq new_order.guest_token }
        it { expect(created_order.store).to eq new_order.store }
        it { expect(created_order.user).to eq new_order.user }
        it { expect(created_order.created_by).to eq new_order.created_by }
        it { expect(created_order.last_ip_address).to eq new_order.last_ip_address }
        it { expect(created_order.state).to eq "cart" }
      end

      context "#add_variant_to_order" do
        it { expect(created_order_with_variant.line_items.count).to eq 1 }
        it { expect(created_order_with_variant.state).to eq "address" }
      end

      context "#add_shipping_address" do
        it { expect(created_order_with_addresses.ship_address).to_not be_nil }
        it { expect(created_order_with_addresses.bill_address).to_not be_nil }
        it { expect(created_order_with_addresses.state).to eq "delivery" }
      end

      context "#add_delivery_method_to_order" do
        let(:parent_order_shipping_method_id) { active_subscription.parent_order.inventory_units.where(variant_id: active_subscription.variant.id).first.shipment.shipping_method.id }
        let(:subscription_order_shipping_method_id) { created_order_with_delivery_method.shipments.first.shipping_rates.find_by(selected: true).shipping_method_id }

        before do
          active_subscription.send :add_delivery_method_to_order, created_order_with_delivery_method
        end

        it 'is expected to select shipping method same to parent order' do
          expect(parent_order_shipping_method_id).to eq(subscription_order_shipping_method_id)
        end

        it { expect(created_order_with_delivery_method.state).to eq "payment" }
      end

      describe '#add_shipping_costs_to_order' do
        it 'is expected to call set_shipments_cost' do
          expect(created_order_with_delivery_method).to receive(:set_shipments_cost)
        end

        after { active_subscription.send :add_shipping_costs_to_order, created_order_with_delivery_method }
      end

      context "#add_payment_method_to_order" do
        it { expect(created_order_with_payment_method.payments.count).to eq 1 }
        it { expect(created_order_with_payment_method.payments.first.source).to eq active_subscription.source }
        it { expect(created_order_with_payment_method.state).to eq "confirm" }
      end

      context "#confirm_order" do
        it { expect(created_order_with_confirmation.state).to eq "complete" }
      end

      context "#recreate_order" do
        let(:recreated_order) { active_subscription.send :recreate_order }
        it { expect(recreated_order.bill_address).to eq created_order_with_confirmation.bill_address }
        it { expect(recreated_order.ship_address).to eq created_order_with_confirmation.ship_address }
        it { expect(recreated_order.payments.first.source).to eq active_subscription.source }
        it { expect(recreated_order).to be_completed }
      end

      describe '#update_next_occurrence_at' do
        before { active_subscription.send :update_next_occurrence_at }

        it { is_expected.to callback(:update_next_occurrence_at).after(:update) }

        it 'is expected to update next_occurrence_at column' do
          expect(active_subscription.next_occurrence_at.to_i).to eq(active_subscription.send(:next_occurrence_at_value).to_i)
        end
      end
    end

    context "#process" do
      before { active_subscription.parent_order.inventory_units.update_all(variant_id: active_subscription.variant.id) }

      context 'when product is discontinued' do
        before do
          active_subscription.variant.product.update_column(:discontinue_on, Time.current - 1.day)
        end

        it 'is expected to update next_occurrence_possible to false' do
          active_subscription.process
          expect(active_subscription.next_occurrence_possible).to eq(false)
        end

        it 'is expected not to create an order' do
          expect { active_subscription.process }.not_to change { active_subscription.complete_orders.count }
        end
      end

      context 'when variant does not have enough stock' do
        before do
          active_subscription.variant.stock_items.update_all(count_on_hand: 0)
        end

        context 'when variant is backorderable' do
          before do
            active_subscription.variant.stock_items.first.update_column(:backorderable, true)
          end

          it 'is expected to update next_occurrence_possible to true' do
            active_subscription.process
            expect(active_subscription.next_occurrence_possible).to eq(true)
          end

          it 'is expected not to create an order' do
            expect { active_subscription.process }.to change { active_subscription.complete_orders.count }.by 1
          end
        end

        context 'when variant is not backorderable' do
          before do
            active_subscription.variant.stock_items.update_all(backorderable: false)
          end

          it 'is expected to update next_occurrence_possible to false' do
            active_subscription.process
            expect(active_subscription.next_occurrence_possible).to eq(false)
          end

          it 'is expected not to create an order' do
            expect { active_subscription.process }.not_to change { active_subscription.complete_orders.count }
          end
        end
      end

      context 'when variant has enough stock' do
        before do
          active_subscription.variant.stock_items.first.update_column(:count_on_hand, active_subscription.quantity)
        end

        it 'is expected to update next_occurrence_possible to true' do
          active_subscription.process
          expect(active_subscription.next_occurrence_possible).to eq(true)
        end

        it 'is expected not to create an order' do
          expect { active_subscription.process }.to change { active_subscription.complete_orders.count }.by 1
        end
      end

      context "when no deliveries remaining" do
        before do
          active_subscription.delivery_number = 1
          active_subscription.process
        end
        it { expect(active_subscription.reload.complete_orders.count).to eq 0 }
        it { expect(active_subscription).to_not be_next_occurrence_at_changed }
      end

      context "when deliveries_remaining" do
        it { expect { active_subscription.process }.to change { active_subscription.complete_orders.count }.by 1 }
      end
    end

    context "mail sending methods" do
      context "#notify_reoccurrence" do
        it { expect { active_subscription.send :notify_reoccurrence }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by 1 }
      end

      context "#notify_cancellation" do
        it { expect { active_subscription.send :notify_cancellation }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by 1 }
      end

      context "#notify_user" do
        it { expect { active_subscription.send :notify_user }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by 1 }
      end

      context "#send_prior_notification" do
        before do
          active_subscription.next_occurrence_at = just_passed_time + 3.days
          active_subscription.prior_notification_days_gap = active_subscription.next_occurrence_at.to_date - Time.current.to_date
        end
        context "is eligible_for_prior_notification" do
          it { expect { active_subscription.send :send_prior_notification }.to change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }.by 1 }
        end
        context "is not eligible_for_prior_notification" do
          before do
            active_subscription.prior_notification_days_gap = 1.day
          end
          it { expect { active_subscription.send :send_prior_notification }.to change { ActionMailer::Base.deliveries.count }.by 0 }
        end
      end
    end
  end

end
