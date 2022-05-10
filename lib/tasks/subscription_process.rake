namespace :subscription do
  desc "process all subscriptions whom orders are to be created"
  task process: :environment do |t, args|
    # Spree::Subscriptions::LabelStatus.processable.find_in_batches do |batches|
    #   batches.map{ |subscription| subscription.process }
    # end

    Spree::Subscriptions::Period.eligible_for_subscription.find_in_batches do |batches|
      batches.map(&:process)
    end
  end
end
