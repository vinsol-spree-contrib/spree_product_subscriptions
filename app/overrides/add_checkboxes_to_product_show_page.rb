Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "add_checkboxes_to_cart_form",
  insert_before: "erb[loud]:contains('hidden_field_tag')",
  partial: "spree/products/cart_checkboxes"
)
