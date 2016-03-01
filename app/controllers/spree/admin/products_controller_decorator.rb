Spree::Admin::ProductsController.class_eval do

  prepend_before_action :filter_subscribable_result, only: :index

  private

    def filter_subscribable_result
      params[:q].delete(:subscribable_eq) if params.fetch(:q, {})[:subscribable_eq] == "0"
    end

end
