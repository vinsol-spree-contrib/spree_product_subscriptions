module SpreeItemsSubscriptions
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_items_subscriptions'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.after_initialize do
      Rails.application.config.spree.promotions.rules.concat [
        Spree::Promotion::Rules::SubscribableProduct
      ]
    end

    initializer "preferences", after: "spree.environment" do |app|
      Spree::AppConfiguration.class_eval do
        preference :promotion_for_only_first_order, :boolean, :false
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
