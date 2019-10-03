Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'add_subscription_label_status_in_configurations',
  insert_bottom: "[data-hook='admin_configurations_sidebar_menu']",
  text: %q{
    <%= configurations_sidebar_menu_item(Spree.t(:subscription_label_statuses), admin_subscription_label_statuses_path) %>
    }
)
