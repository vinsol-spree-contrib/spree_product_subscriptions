module Spree
  module Subscriptions
    class LabelStatus < ::Spree::Subscription
      alias_attribute :frequency, :label_status

      with_options presence: true do
        validates :label_status
      end

      def process
        new_order = recreate_order
      end
    end
  end
end
