Spree.ready(function($) {
  Spree.addToCartFormSubmissionOptions = function() {
    $cartForm = $(ADD_TO_CART_FORM_SELECTOR);
    if($cartForm.find('.cart_radio_button:checked').val() == ".subscription_options") {
      options = {
        subscribe: true,
        subscription_frequency_id: $cartForm.find('#subscription_subscription_frequency_id option:selected').val(),
        delivery_number: parseInt($cartForm.find('#subscription_delivery_number').val())
      };
      return options;
    }
    return {};
  }
})