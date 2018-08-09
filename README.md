# Polipay

An unofficial Ruby (and Rails) API client for [POLi Payments](https://www.polipayments.com/Developer).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'polipay'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install polipay

## Usage

![A typical Poli flow](https://www.polipayments.com/Images/DevWiki/apiflow1.png)

A Poli transaction consists of 3 parts:

1. An [`InitiateTransaction`](https://www.polipayments.com/InitiateTransaction) call that sets up the transaction and returns a url/token that you can redirect (or iframe) a user to perform the payment.
2. A callback aka the [`Nudge`](https://www.polipayments.com/Nudge) that returns the token once the payment has completed in one way or other (e.g. success, failure or timeout)
3. A [`GetTransaction`](https://www.polipayments.com/GetTransaction) call to find out the status and transaction details.

This client provides an interface for each of the required API calls:

```ruby
initiate_transaction = Polipay::InitiateTransaction.perform amount: 100, merchant_reference: 'MERCHANT_REF'
puts initiate_transaction.NavigateURL # https://txn.apac.paywithpoli.com/?Token=uo3K8YA7vCojXjA1yuQ3txqX4s26gQSh

get_transaction = Polipay::GetTransaction.perform token: 'uo3K8YA7vCojXjA1yuQ3txqX4s26gQSh'
puts get_transaction.TransactionStatusCode # EulaAccepted
```

The nudge (callback) is also able to be handled in Rack based (and Rails) app via a Rack middleware.
If this middleware is used the `GetTransaction` method is automatically called and the transaction is returned for consumption.

```ruby
Polipay.on_nudge do |nudge, transaction|
  puts nudge.token # uo3K8YA7vCojXjA1yuQ3txqX4s26gQSh
  puts transaction.TransactionStatusCode # EulaAccepted
  # typically you'd want to pass the `transaction` off to a background job or something like that.
end
```

`InitiateTransaction` supports these arguments: `amount`, `merchant_reference`, `merchant_data`, `selected_fi_code`. The other parameters for the underlying API call are configured via `Polipay.configure` as below.

There are two other API calls that are not currently supported - [`GetDailyTransaction`](https://www.polipayments.com/GetDailyTransaction) and [`GetFinancialInstitution`](https://www.polipayments.com/GetFinancialInstitution).

### Configuration

In Rails a Railtie is provided to automatically mount the Rack middleware, all you need to do is configure and pass a block to be called when the Nudge is received.

```ruby
# app/initalizers/polipay.rb
Polipay.configure do |config|
  config.merchant_code = 'foo' # required - per your account set up, no default
  config.authentication_code = 'bar' # required - per your account set up, no default
  config.currency_code = 'NZD' # required (AUD or NZD) - per your account set up, no default
  config.success_path = '/success' # required (or success_url), no default
  config.cancellation_path = '/cancellation' # required (or cancellation_url), no default
  config.failure_path = '/failure' # required (or failure_url), no default
  config.merchant_homepage_url = 'https://ecommerce.example.com' # required, no default

  config.mount_point = '/polipay' # optional
  config.logger = Logger.new STDOUT # optional
  config.raise_exceptions = true unless ENV['RACK_ENV'] == 'production' # optional
  config.merchant_api_url = 'https://poliapi.apac.paywithpoli.com/api/v2/'
  config.merchant_reference_format = # no default, required for NZ merchants see https://www.polipayments.com/NZreconciliation
  config.timeout = # optional, no client default (currently 900 seconds from POLi)
end

Polipay.on_nudge do |nudge, transaction|
  order = Order.find_by(poli_token: nudge.token)
  OrderPlacementJob.perform_later order, transaction
end

```

In a Rack app (Sinatra etc) you'll need to `require 'polipay/middleware'` and add `Polipay::Middleware` to your stack.
This mounts to `/polypay` to accept a POST, this `mount_point` is configurable.

If you configure `merchant_homepage_url` (required) and `success_path` the path is appended to the homepage URL - this is the same for the two other paths - via `failure_path` and `cancellation_path`
The methods with the suffix `_url` e.g. `success_url` are full URLs and if configured are used _in preference to_ the path options.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/etailer/polipay.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
