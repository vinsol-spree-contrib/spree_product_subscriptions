Deface::Override.new(
  virtual_path: 'spree/orders/show',
  name: 'add_subscription_number_to_order_page',
  insert_after: "fieldset#order_summary h1",
  partial: 'spree/orders/subscription_number'
)
