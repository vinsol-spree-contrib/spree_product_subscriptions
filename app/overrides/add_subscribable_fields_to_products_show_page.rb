Deface::Override.new(
  virtual_path: "spree/products/_cart_form",
  name: "add_subscribable_fields_to_products_show",
  insert_after: ".input-group",
  text: "<% if @product.subscribable? %>
          <span class='input-group-btn'>
            <%= button_tag class: 'btn btn-success', id: 'subscribe-button', type: :submit, name: :subscribe, value: '1' do %>
              <%= Spree.t(:subscribe_now) %>
            <% end %>
          </span>
          <% subscription = Spree::Subscription.new %>
          <span>
            <%= collection_select :subscription, :subscription_frequency_id, @product.subscription_frequencies, :id, :title %>
          </span>
          <br>
          <span>
            <%= date_select :subscription, :end_date, { default: Date.today }, {} %>
          </span>
        <% end %>"
)
