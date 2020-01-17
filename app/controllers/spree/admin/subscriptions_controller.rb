module Spree
  module Admin
    class SubscriptionsController < ResourceController

      before_action :ensure_not_cancelled, only: [:update, :cancel, :cancellation, :pause, :unpause]

      def cancellation
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

        def cancel_subscription_attributes
          params.require(:subscription).permit(:cancellation_reasons)
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
