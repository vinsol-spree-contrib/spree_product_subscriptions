module Spree
  module PresenterHelper

  	extend ActiveSupport::Concern

    def presenter
      "#{ self.class }Presenter".constantize.new(self)
    end

  end
end
