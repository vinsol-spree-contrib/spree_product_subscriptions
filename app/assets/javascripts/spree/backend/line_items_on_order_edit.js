// This file contains the code for interacting with line items in the manual cart
$(document).ready(function () {
  'use strict';

  // handle variant selection, show stock level.
  $('#add_line_item_variant_id').change(function(){
    var variant_id = $(this).val();

    var variant = _.find(window.variants, function(variant){
      return variant.id == variant_id
    })

    $('#stock_details').html(variantLineItemTemplate({variant: variant}));
    $('#stock_details').show();

    $('button.add_variant').click(addVariant);

    //Function added for susbcription orders
    disableSubscriptionFieldsOnOneTimeOrder(variant_id);
  });
});

addVariant = function() {
  $('#stock_details').hide();

  var variant_id = $('input.variant_autocomplete').val();
  var quantity = $("input.quantity[data-variant-id='" + variant_id + "']").val();
  // fields added for making subscription order.
  var subscribe = $("input.subscribe[data-variant-id='" + variant_id + "']:checked").val();
  var frequency = $("select#frequency[data-variant-id='" + variant_id + "']").val();

  adjustLineItems(order_number, variant_id, quantity, subscribe, frequency);
  return 1
}

// function modified for subscription order fields
adjustLineItems = function(order_number, variant_id, quantity, subscribe, frequency){
  var url = Spree.routes.orders_api + "/" + order_number + '/line_items';

  $.ajax({
    type: "POST",
    url: Spree.url(url),
    data: {
      line_item: {
        variant_id: variant_id,
        quantity: quantity,
        options: { subscribe: subscribe,
          subscription_frequency_id: frequency
        }
      },
      token: Spree.api_key
    }
  }).done(function( msg ) {
    window.Spree.advanceOrder();
    window.location.reload();
  }).fail(function(msg) {
    alert(msg.responseJSON.message)
  });

}

// Function added for subscription fields
disableSubscriptionFieldsOnOneTimeOrder = function(variant_id) {
  var frequency = $("select#frequency[data-variant-id='" + variant_id + "']");
  $("input.subscribe[data-variant-id='" + variant_id + "']").on("change", function() {
    if (!parseInt($(this).val())) {
      frequency.attr("disabled", "disabled");
    } else {
      frequency.removeAttr("disabled");
    }
  });
}
