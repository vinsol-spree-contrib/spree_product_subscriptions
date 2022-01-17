module Spree
  class SubscriptionsController < Spree::StoreController
    include Spree::Core::ControllerHelpers::Order

    before_action :ensure_subscription
    before_action :ensure_subscription_belongs_to_user, only: [:edit, :edit_payment_details]
    before_action :ensure_not_cancelled, only: [:update, :cancel, :pause, :unpause]
    before_action :set_needed_attributes, only: [:edit, :update, :edit_payment_details]

    def edit
      @subscription = Spree::Subscription.find(params[:id]).becomes(Spree::Subscription)
    end

    def update
      if @subscription.update(subscription_attributes)
        respond_to do |format|
          format.html { redirect_to edit_subscription_path(@subscription), success: t('.success') }
          format.json { render json: { subscription: { price: @subscription.price, id: @subscription.id } }, status: 200 }
        end
      else
        respond_to do |format|
          format.html { render :edit }
          format.json { render json: { errors: @subscription.errors.full_messages.to_sentence }, status: 422 }
        end
      end
    end

    def cancel
      respond_to do |format|
        if @subscription.cancel
          format.json { render json: {
              subscription_id: @subscription.id,
              flash: t(".success"),
              method: Spree::Subscription::ACTION_REPRESENTATIONS[:cancel].upcase
            }, status: 200
          }
          format.html { redirect_to edit_subscription_path(@subscription), success: t(".success") }
        else
          format.json { render json: {
              flash: t(".error")
            }, status: 422
          }
          format.html { redirect_to edit_subscription_path(@subscription), error: t(".error") }
        end
      end
    end

    def pause
      if @subscription.pause
        render json: {
          flash: t('.success'),
          url: unpause_subscription_path(@subscription),
          button_text: Spree::Subscription::ACTION_REPRESENTATIONS[:unpause],
          confirmation: Spree.t("subscriptions.confirm.activate")
        }, status: 200
      else
        render json: {
          flash: t('.error')
        }, status: 422
      end
    end

    def unpause
      next_occurrence_at = @subscription.next_occurrence_at ?
          @subscription.next_occurrence_at.to_date.to_formatted_s(:rfc822) : @subscription.label_status.title
      if @subscription.unpause
        render json: {
          flash: t('.success', next_occurrence_at: next_occurrence_at),
          url: pause_subscription_path(@subscription),
          button_text: Spree::Subscription::ACTION_REPRESENTATIONS[:pause],
          next_occurrence_at: next_occurrence_at,
          confirmation: Spree.t("subscriptions.confirm.pause")
        }, status: 200
      else
        render json: {
          flash: t('.error')
        }, status: 422
      end
    end

    def edit_payment_details
    end

    def update_payment_details
      if @subscription.update(new_source_attributes)
        respond_to do |format|
          format.html { redirect_to edit_subscription_path(@subscription), success: t('.success') }
        end
      else
        respond_to do |format|
          set_needed_attributes
          format.html { render :edit_payment_details, error: @subscription.errors.full_messages.to_sentence }
          format.json { render json: { flash: @subscription.errors.full_messages.to_sentence }, status: 422 }
        end
      end
    end

    private

    def set_needed_attributes
      @order = (@subscription.orders.last || @subscription.parent_order)
      @payment_sources = @order.user.payment_sources.order(:default).reverse
    end

    def billing_address_attributes
      params.require(:subscriptions_label_status).permit(
        :bill_address_id,
        bill_address_attributes: [
          :firstname, :lastname, :company, :address1, :address2, :city,
          :state_id, :state_name, :zipcode, :country_id, :phone, :id
        ]
      )
    end

    def subscription_attributes
      params.require(:subscription).permit(
        :quantity, :next_occurrence_at, :subscription_frequency_id,
        :subscription_label_status_id, :variant_id, :prior_notification_days_gap,
        ship_address_attributes: [
          :firstname, :lastname, :address1, :address2, :city, :zipcode, :country_id, :state_id, :phone
        ],
        bill_address_attributes: [
          :firstname, :lastname, :address1, :address2, :city, :zipcode, :country_id, :state_id, :phone
        ]
      )
    end

    def new_source_attributes
      {
        new_source_attributes: {
          existing_card: existing_card_attribute,
          payment_attributes: payment_attributes,
          source_attributes: payment_source_attributes,
          billing_address_attributes: billing_address_attributes
        }
      }
    end

    def existing_card_attribute
      @use_credit_card ||= (params.require(:use_existing_card) == 'yes')
    end

    def payment_attributes
      @payment_attributes ||= (
        params.require(:order).permit(:existing_card, payments_attributes: :payment_method_id)
      )
    end

    def payment_source_attributes
      @payment_source_attributes ||= (
        payment_source_ids = params[:payment_source].keys
        attributes = payment_source_ids.inject({}) do |attributes, payment_source_id|
          attributes[:"#{payment_source_id}"]= [:name, :number, :expiry, :verification_value, :cc_type, :po_number]
          attributes
        end
        params.require(:payment_source).permit(attributes)[payment_source_ids[0]]
      )
    end

    def ensure_subscription
      @subscription = Spree::Subscription.active.find_by(id: params[:id])
      unless @subscription
        respond_to do |format|
          format.html { redirect_to account_path, error: Spree.t('subscriptions.alert.missing') }
          format.json { render json: { flash: Spree.t("subscriptions.alert.missing") }, status: 422 }
        end
      end
    end

    def ensure_not_cancelled
      if @subscription.not_changeable?
        respond_to do |format|
          format.html { redirect_back fallback_location: root_path, error: Spree.t("subscriptions.error.not_changeable") }
          format.json { render json: { flash: Spree.t("subscriptions.error.not_changeable") }, status: 422 }
        end
      end
    end

    def ensure_subscription_belongs_to_user
      authorize! :update, @subscription
    end

  end
end
