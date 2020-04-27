module Spree
  module SubscriptionsHelper
    def days_left_for_next_occurrence
      (@subscription.next_occurrence_at.to_date - Date.current).to_i
    end
  end
end
