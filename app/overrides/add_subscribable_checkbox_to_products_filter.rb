Deface::Override.new(
  virtual_path: 'spree/admin/products/index',
  name: 'add_subscribable_filter_to_products',
  insert_bottom: "[data-hook='admin_products_index_search'] .col-md-12",
  partial: "spree/admin/products/subscribable_filter"
)
