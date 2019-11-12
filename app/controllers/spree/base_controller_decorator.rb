module Spree::BaseControllerDecorator
  def self.prepended(base)
    base.add_flash_types :success, :error
  end
end

::Spree::BaseController.prepend(Spree::BaseControllerDecorator)
