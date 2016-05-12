module Spree
  class SubscriptionsController < Spree::BaseController

    before_action :ensure_subscription
    before_action :ensure_not_cancelled, only: [:update, :cancel, :pause, :unpause]
    before_action :update_params, only: :update

    def edit
      reload_variables
    end

    def update
      if @subscription.update(subscription_attributes)
        respond_to do |format|
          format.html { redirect_to edit_subscription_path(@subscription), success: t('.success') }
          format.json { render json: { subscription: { price: @subscription.price, id: @subscription.id } }, status: 200 }
        end
      else
        reload_variables
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
      if @subscription.unpause
        render json: {
          flash: t('.success', next_occurrence_at: @subscription.next_occurrence_at.to_date.to_formatted_s(:rfc822)),
          url: pause_subscription_path(@subscription),
          button_text: Spree::Subscription::ACTION_REPRESENTATIONS[:pause],
          next_occurrence_at: @subscription.next_occurrence_at.to_date,
          confirmation: Spree.t("subscriptions.confirm.pause")
        }, status: 200
      else
        render json: {
          flash: t('.error')
        }, status: 422
      end
    end

    private

      def subscription_attributes
        params.require(:subscription).permit(:quantity, :next_occurrence_at, :delivery_number,
          :subscription_frequency_id, :variant_id, :prior_notification_days_gap, :source_id,
          ship_address_attributes: [:firstname, :lastname, :address1, :address2, :city, :zipcode, :country_id, :state_id, :phone],
          bill_address_attributes: [:firstname, :lastname, :address1, :address2, :city, :zipcode, :country_id, :state_id, :phone])
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

      def update_params
        if params[:use_another_card]
          if params[:use_existing_card] == 'no'
            params[:subscription].merge!(source_id: create_credit_card.try(:id))
          elsif params[:use_existing_card] == 'yes'
            params[:subscription].merge!(source_id: params[:order][:existing_card])
          end
        end
      end

      def create_credit_card
        subscription_user.credit_cards.build(card_params) || nil
      end

      def reload_variables
        @subscription.reload
        @credit_cards = subscription_user.credit_cards.select(&:persisted?) - [@subscription.source]
        @order = @subscription.parent_order
      end

      def card_params
        params[:payment_source]['1'].merge!(payment_method_id: subscription_user.credit_cards.first.payment_method_id)
        params[:payment_source].require('1').permit(:name, :number, :expiry, :verification_value, :cc_type, :payment_method_id)
      end

      def subscription_user
        try_spree_current_user
      end

      def ensure_not_cancelled
        if @subscription.not_changeable?
          respond_to do |format|
            format.html { redirect_to :back, error: Spree.t("subscriptions.error.not_changeable") }
            format.json { render json: { flash: Spree.t("subscriptions.error.not_changeable") }, status: 422 }
          end
        end
      end

  end
end
