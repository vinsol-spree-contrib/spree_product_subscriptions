class SubscribeButtonToggler {

  constructor($subscribeButton, $variantElement) {
    this.$subscribeButton = $subscribeButton;
    this.$variantsList = $variantElement.children('li');
    this.$variantRadioList = $variantElement.find('input[type="radio"]');
  }

  init() {
    this.bindEvent();
    this.toggleSubscribeButtonIfVariantIsSelected();
  }

  bindEvent() {
    let _this = this;
    this.$variantRadioList.on('change', function() {
      _this.toggleSubscribeButtonIfVariantIsSelected();
    });
  }

  toggleSubscribeButtonIfVariantIsSelected() {
    let _this = this;
    this.$variantsList.each( function() {
      if($(this).find('input[type="radio"]:checked').length > 0) {
        _this.toggleSubscribeButton(false);
      }
      else {
        _this.toggleSubscribeButton(true);
        return false;
      }
    });
  }

  toggleSubscribeButton(value) {
    this.$subscribeButton.prop('disabled', value);
  }
}

$(() => {
  let $subscribeButton = $('#subscribe-button');
  let $variantElement = $('#product-variants');
  new SubscribeButtonToggler($subscribeButton, $variantElement).init();
})