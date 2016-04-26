Deface::Override.new(
  virtual_path: "spree/admin/general_settings/edit",
  name: "add_subscription_settings",
  insert_before: ".form-actions",
  partial: "spree/admin/subscriptions/general_settings"
)
