function ProductQuantity(data) {
  this.oneTimeOrderQuantity = data.oneTimeOrderQuantity;
  this.subscriptionQuantity = data.subscriptionQuantity;
}

ProductQuantity.prototype.init = function() {
  var _this = this;
  this.oneTimeOrderQuantity.change(function() {
    _this.subscriptionQuantity.val(this.value);
  })
};

$(function() {
  var cartInputFields = $('input#quantity');
  var data = {
    oneTimeOrderQuantity: cartInputFields.eq(0),
    subscriptionQuantity: cartInputFields.eq(1)
  }
  var productQuantity = new ProductQuantity(data);
  productQuantity.init();
})
