Deface::Override.new(
  virtual_path: "spree/products/_product",
  name: "add_subscribable_label_to_index_page",
  insert_top: ".product-body",
  partial: 'spree/products/banner'
)

Deface::Override.new(
  virtual_path: 'spree/products/_product',
  name: 'add_class_to_parent_div',
  add_to_attributes: '.product-body',
  attributes: { "class": 'pos-rel' }
)
