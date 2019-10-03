namespace :subscription do
  desc "process all subscriptions whom orders are to be created"
  task process: :environment do |t, args|
  	Spree::LabelStatusSubscription.processable.includes(orders: {shipments: :labels}).references(orders: {shipments: :labels}).find_in_batches do |batches|
  	  batches.map{ |subscription| subscription.process if subscription.can_be_proccesed? }
  	end

    Spree::TimeSubscription.eligible_for_subscription.find_in_batches do |batches|
      batches.map(&:process)
    end
  end
end
