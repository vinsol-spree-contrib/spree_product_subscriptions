Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name: 'add_subscribable_to_product_edit',
  insert_after: "[data-hook='admin_product_form_description']",
  partial: 'spree/admin/products/subscribable',
)
