module Spree
  module Admin
    class SubscriptionsController < Spree::Admin::ResourceController

      before_action :ensure_not_cancelled, only: [:update, :cancel, :cancellation, :pause, :unpause]
      before_action :update_params, only: :update
      
      def cancellation
      end

      def edit
        reload_variables
      end

      def cancel
        if @subscription.cancel_with_reason(cancel_subscription_attributes)
          redirect_to collection_url, success: t('.success')
        else
          render :cancellation
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

        def update_params
          if params[:use_another_card]
            if params[:use_existing_card] == 'no'
              credit_card = subscription_user.credit_cards.create(card_params)
              params[:subscription].merge!(source_id: credit_card.id)
            elsif params[:use_existing_card] == 'yes'
              params[:subscription].merge!(source_id: params[:order][:existing_card])
            end
          end
          params[:subscription].delete(:source_attributes)
        end

        def card_params
          params[:payment_source]['1'].merge!(payment_method_id: subscription_user.credit_cards.first.payment_method_id)
          params[:payment_source].require('1').permit(:name, :number, :expiry, :verification_value, :cc_type, :payment_method_id)
        end


        def subscription_user
          @subscription.parent_order.user
        end

        def cancel_subscription_attributes
          params.require(:subscription).permit(:cancellation_reasons)
        end

        def reload_variables
          @subscription.reload
          @credit_cards = subscription_user.credit_cards.select(&:persisted?) - [@subscription.source]
          @order = @subscription.parent_order
        end

        def collection
          @search = super.active.ransack(params[:q])
          @collection = @search.result.includes(:frequency, :complete_orders, variant: :product)
                                      .references(:complete_orders)
                                      .order(created_at: :desc)
                                      .page(params[:page])
        end

        def ensure_not_cancelled
          if @subscription.cancelled?
            redirect_to collection_url, error: Spree.t("admin.subscriptions.error_on_already_cancelled")
          end
        end

    end
  end
end
