Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "add_class_to_add_to_cart_div_on_products_show_page",
  set_attributes: "#inside-product-cart-form div:nth-of-type(3)",
  attributes: { class: 'add-to-cart' }
)
