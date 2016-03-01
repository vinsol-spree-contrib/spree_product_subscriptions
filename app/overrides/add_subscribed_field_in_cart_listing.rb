Deface::Override.new(
  virtual_path: "spree/orders/_line_item",
  name: "add_subscribed_field_to_cart_listing",
  insert_bottom: ".line-item",
  text: "<td class='cart-item-subscription' data-hook='cart_item_subscription'>
          <% subscription = @order.subscriptions.find_by(variant: variant) %>
          <% if subscription %>
            Subscribed <%= @order.subscriptions.find_by(variant: variant).frequency.title %>
          <% else %>
            Not Subscribed
          <% end %>
        </td>"
)
