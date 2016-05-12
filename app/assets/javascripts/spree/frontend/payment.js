Spree.ready(function($) {
  Spree.updatePaymentMethod = function() {
    if (($('.edit_subscription')).is('*')) {
      if (($('#existing_cards')).is('*')) {
        ($('.clearfix')).hide();
        ($('#use_existing_card_yes')).click(function() {
          ($('.clearfix')).hide();
          return ($('.existing-cc-radio')).prop("disabled", false);
        });
        ($('#use_existing_card_no')).click(function() {
          ($('.clearfix')).show();
          return ($('.existing-cc-radio')).prop("disabled", true);
        });
      }
      ($('#payment')).hide();
      $("#use_another_card").change(function() {
        if($(this).is(':checked')) {
          ($('#payment')).show();
        } else {
          ($('#payment')).hide();
        }
      });
      $(".cardNumber").payment('formatCardNumber');
      $(".cardExpiry").payment('formatCardExpiry');
      $(".cardCode").payment('formatCardCVC');
      $(".cardNumber").change(function() {
        return $(this).parent().siblings(".ccType").val($.payment.cardType(this.value));
      });
      ($(document)).on('click', '#cvv_link', function(event) {
        var windowName, windowOptions;
        windowName = 'cvv_info';
        windowOptions = 'left=20,top=20,width=500,height=500,toolbar=0,resizable=0,scrollbars=1';
        window.open(($(this)).attr('href'), windowName, windowOptions);
        return event.preventDefault();
      });
    }
  };
  return Spree.updatePaymentMethod();
});
