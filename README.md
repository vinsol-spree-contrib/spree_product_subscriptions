Spree Product Subscriptions
===========================

Spree Product Subscriptions is an extension to let users have time interval based subscription of products in a spree application.

* This extension allows the admin to create a subscribable product on the Admin end.

* This product can then be bought one-time or as a subscription.

* Once subscribed, subscription orders will automatically be created for the user at the selected time interval.

Demo
----
Try Spree Product Subscriptions for Spree master with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-product-subscriptions-master)

Try Spree Product Subscriptions for Spree 4 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-product-subscriptions-4-1)

Try Spree Product Subscriptions for Spree 3-4 with direct deployment on Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/vinsol-spree-contrib/spree-demo-heroku/tree/spree-product-subscriptions-3-4)

Installation
------------

Add spree_product_subscriptions to your Gemfile:

```ruby
gem 'spree_product_subscriptions', github: 'vinsol-spree-contrib/spree_product_subscriptions'
```

Bundle your dependencies and run the installation generator:

```shell
bundle
bundle exec rails g spree_product_subscriptions:install
```

You can also seed the default data with:
```shell
bundle exec rails g spree_product_subscriptions:seed
```

Working
-------

* Admin can mark a product as "subscribable" on the `Admin -> Products -> Edit` page. The admin will have to choose the subscription frequencies to be made available for that product.

* Subscription frequencies are created by default when you seed data. You can also add subscription frequencies through `Admin -> Configurations -> Subscription Frequencies -> New` page.

* When user is purchasing a subscribable product, he gets an option to make it a 'One Time Order' or a 'Subscription Order'.

* When making a 'Subscription Order', the user will have to choose Delivery Interval, Total Deliveries, and Quantity. The first order will be made on checkout and remaining orders will automatically be created for the user at the selected time intervals.

* The users can check their subscriptions on the 'My Account' page. They can update subscription info, pause or cancel their subscriptions via the `Subscription -> Edit` page.

* A cron job needs to be run to process subscriptions
  ```
  bundle exec rake subscription:process
  ```
  This will run the pending subscriptions.

* A cron job can also be run to notify users of upcoming subscriptions:
  ```
  bundle exec rake subscription:prior_notify
  ```
  This will inform users that they have a subscription that is coming up in 'x' days. The number of days can be changed on subscription edit page.

**Here is a detailed article with screenshot http://vinsol.com/spreecommerce-subscription**
Testing
-------

Be sure to bundle your dependencies and then create a dummy test app for the specs to run against.

```shell
bundle
bundle exec rake test_app
bundle exec rspec spec
```

When testing your applications integration with this extension you may use it's factories.
Simply add this require statement to your spec_helper:

```ruby
require 'spree_product_subscriptions/factories'
```

## See It In Action

<a href="http://www.youtube.com/watch?feature=player_embedded&v=bXJfJSWHspo
" target="_blank"><img src="http://img.youtube.com/vi/bXJfJSWHspo/0.jpg" 
alt="Youtube Video Tutorial" /></a>

Credits
-------

[![vinsol.com: Ruby on Rails, iOS and Android developers](http://vinsol.com/themes/vinsoldotcom-theme/images/new_img/vin_logo.png "Ruby on Rails, iOS and Android developers")](http://vinsol.com)

Copyright (c) 2016 [vinsol.com](http://vinsol.com "Ruby on Rails, iOS and Android developers"), released under the New MIT License
