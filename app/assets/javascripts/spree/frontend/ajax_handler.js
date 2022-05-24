function AjaxHandler(targets, lineItemsTable) {
  this.targets = targets;
  this.lineItemsTable = lineItemsTable;
}

AjaxHandler.prototype.init = function() {
  this.bindEvents();
};

AjaxHandler.prototype.bindEvents = function() {
  var _this = this;

  $.each(_this.targets, function(index, target) {
    var $target = $(target);
    $target.unbind('click').on('click', function() {
      var data = $target.data();
      if(confirm(data.confirmation)) {
        _this.sendRequest($target, data);
      }
    });
  });

  _this.lineItemsTable.on('change', '#subscription_variant_id', function(){
    _this.updateVariant(this);
  });

};

AjaxHandler.prototype.updateVariant = function(variant_select) {
  var _this = this;
  $.ajax({
    url: '/subscriptions/' + $(variant_select).data('subscription-id'),
    dataType: "JSON",
    method: 'PUT',
    data: {
      id: $(variant_select).data('subscription-id'),
      subscription: {
        variant_id: $(variant_select).children(':selected').val()
      }
    },
    success: function(response) {
      var subscription = response['subscription'];
      var $lineItemPrice = _this.lineItemsTable.find('td.line-item-price')
        .find('[data-subscription-id="'+ subscription['id'] +'"]');
      $lineItemPrice.html(subscription['price']);
      show_flash('success', 'Variant has been updated.');
    },
    error: function(response) {
      errors = JSON.parse(response.responseText).errors;
      show_flash('danger', errors);
    }
  });
};

AjaxHandler.prototype.sendRequest = function($target, data) {
  var _this = this;
  $.ajax({
    url: data.url,
    dataType: "JSON",
    method: data.method,
    headers: {
      'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
    },
    success: function(response) {
      if (response.method == "CANCEL") {
        _this.handleCancelSuccess($target, response);
      } else {
        _this.handlePatchSuccess($target, response)
      }
    },
    error: function(response) {
      _this.handleErrorResponse($target, response);
    }
  });
};

show_flash = function(type, message) {
  var flash_div = $('.flash.' + type);
  if (flash_div.length == 0) {
    flash_div = $('<div class="alert alert-' + type + '" />');
    $('#content').prepend(flash_div);
  }
  flash_div.html(message).show().delay(5000).slideUp();
}

AjaxHandler.prototype.handlePatchSuccess = function($target, response) {
  this.hideFlashDivs();
  $target.data("url", response.url);
  if (response.url.match("unpause")) {
    $(".subscription_next_occurrence_at").attr("disabled", "disabled");
  } else {
    $(".subscription_next_occurrence_at").val(response.next_occurrence_at);
    $(".subscription_next_occurrence_at").removeAttr("disabled");
  }
  $("#success_flash_message").html(response.flash).removeClass("d-none");
  var $symbol = $target.find(".icon");
  $symbol.toggleClass("icon-pause").toggleClass("icon-play");
  if (!$target.find(".translation_missing").length && !$symbol.length) {
    $target.html(response.button_text);
  }
  $target.find(".translation_missing").html(response.button_text);
  $target.data("confirmation", response.confirmation);
};

AjaxHandler.prototype.handleCancelSuccess = function($target, response) {
  this.hideFlashDivs();
  $("#success_flash_message").html(response.flash).removeClass("d-none");
  $('[data-id="' + response.subscription_id + '"] .subscription-action-links').html("Subscription Cancelled");
};

AjaxHandler.prototype.handleErrorResponse = function($target, response) {
  this.hideFlashDivs();
  $("#error_flash_message").html(response.flash).removeClass("d-none");
};

AjaxHandler.prototype.hideFlashDivs = function() {
  $("#html_error_flash_message").remove();
  $("#error_flash_message").addClass("d-none");
  $("#html_success_flash_message").remove();
  $("#success_flash_message").addClass("d-none");
};

$(function (){
  var ajaxHandler = new AjaxHandler($('.ajax_handler'), $('table.line-items'));
  ajaxHandler.init();
});
