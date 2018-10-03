# This is temporary. Now we are testing and don't want to deliver email (even on production env)
# to perform mail deliverability remove this file.


Spree::Order.class_eval do
  def send_cancel_email
    # OrderMailer.cancel_email(id).deliver_later
    true
  end

  def deliver_order_confirmation_email
    # OrderMailer.confirm_email(id).deliver_later
    update_column(:confirmation_delivered, true)
  end
end


Spree::Subscription.class_eval do
  def send_prior_notification
    # SubscriptionNotifier.notify_for_next_delivery(self).deliver_later
    true
  end

  def notify_user
    # SubscriptionNotifier.notify_confirmation(self).deliver_later
    true
  end

  def notify_cancellation
    # SubscriptionNotifier.notify_cancellation(self).deliver_later
    true
  end

  def notify_reoccurrence
    # SubscriptionNotifier.notify_reoccurrence(self).deliver_later
    true
  end
end

