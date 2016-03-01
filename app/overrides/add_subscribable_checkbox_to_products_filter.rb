Deface::Override.new(
  virtual_path: 'spree/admin/products/index',
  name: 'add_subscribable_filter_to_products',
  insert_bottom: "[data-hook='admin_products_index_search'] .col-md-12",
  text: "spree/admin/products/_subscribable_filter"
)
