module Spree
  class Promotion
    module Rules
      class SubscribableProduct < PromotionRule
        has_and_belongs_to_many :subscribable_products, -> { where(subscribable: true) }, class_name: '::Spree::Product', join_table: 'spree_products_promotion_rules', foreign_key: 'promotion_rule_id'
        
        MATCH_POLICIES = %w(any all none)
        preference :match_policy, :string, default: MATCH_POLICIES.first

        def eligible_products
          subscribable_products
        end

        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, options = {})
          return true if eligible_products.empty?

          if preferred_match_policy == 'all'
            unless eligible_products.all? {|p| subscribed_products(order).include?(p) }
              eligibility_errors.add(:base, eligibility_error_message(:missing_product))
            end
          elsif preferred_match_policy == 'any'
            unless subscribed_products(order).any? {|p| eligible_products.include?(p) }
              eligibility_errors.add(:base, eligibility_error_message(:no_applicable_products))
            end
          else
            unless subscribed_products(order).none? {|p| eligible_products.include?(p) }
              eligibility_errors.add(:base, eligibility_error_message(:has_excluded_product))
            end
          end 

          eligibility_errors.empty? && applicable_with_preference?(order)
        end

        def applicable_with_preference?(order)
          !Spree::Config.promotion_for_only_first_order || order.parent_subscription.nil?
        end

        def actionable?(line_item)
          case preferred_match_policy
          when 'any', 'all'
            subscribable_product_ids.include? line_item.variant.product_id
          when 'none'
            subscribable_product_ids.exclude? line_item.variant.product_id
          else
            raise "unexpected match policy: #{preferred_match_policy.inspect}"
          end
        end

        def subscribed_products(order)
          if parent_order_present?(order)
            [order.parent_subscription.variant.product]
          else
            order.subscriptions.map(&:variant).map(&:product)
          end
        end

        def parent_order_present?(order)
          order.parent_subscription.present?
        end

        def subscribable_product_ids_string
          subscribable_product_ids.join(',')
        end

        def subscribable_product_ids_string=(ids)
          self.subscribable_product_ids = ids.to_s.split(',').map(&:strip)
        end

      end
    end
  end
end
