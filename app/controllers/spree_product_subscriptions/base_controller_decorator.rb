module SpreeProductSubscriptions
  module BaseControllerDecorator
    def self.prepended(base)
      base.add_flash_types :success, :error
    end
  end
end

::Spree::BaseController.prepend(::SpreeProductSubscriptions::BaseControllerDecorator)
