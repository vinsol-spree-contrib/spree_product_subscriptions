function CartRadioButton($radioButtons) {
  this.$radioButtons = $radioButtons;
}

CartRadioButton.prototype.init = function() {
  this.bindEvents();
};

CartRadioButton.prototype.bindEvents = function() {
  var _this = this;
  this.$radioButtons.on("change", function() {
    _this.toggleDiv($(this));
  });
};

CartRadioButton.prototype.toggleDiv = function($checkBox) {
  let value = $checkBox.val();
  $(value).show();
  if (value.includes('subscription_options')) {
    $('#add-to-cart-button').text('SUBSCRIBE NOW');
  } else {
    $('#add-to-cart-button').text('ADD TO CART');
    $(value).siblings('.subscription_options').hide();
  }
};

$(function() {
  var cartRadioButton = new CartRadioButton($(".cart_radio_button"));
  cartRadioButton.init();
});
