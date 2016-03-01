Deface::Override.new(
  virtual_path: "spree/orders/_line_item",
  name: "add_subscribed_field_to_cart_listing",
  insert_bottom: ".line-item",
  partial: "spree/orders/subscription_field"
)
