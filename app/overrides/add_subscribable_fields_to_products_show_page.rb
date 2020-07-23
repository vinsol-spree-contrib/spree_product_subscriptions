Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "add_class_to_add_to_cart_div",
  set_attributes: "#inside-product-cart-form div:nth-of-type(3)",
  attributes: { class: 'add-to-cart' }
)

Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "add_subscribable_fields_to_products_show",
  insert_after: "erb[loud]:contains('hidden_field_tag')",
  partial: "spree/products/subscription_fields"
)
