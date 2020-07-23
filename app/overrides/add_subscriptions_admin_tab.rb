Deface::Override.new(
  virtual_path: 'spree/admin/shared/_main_menu',
  name: 'subscriptions_admin_tab',
  insert_bottom: 'nav',
  partial: 'spree/admin/shared/subscriptions_sidebar_menu'
)
