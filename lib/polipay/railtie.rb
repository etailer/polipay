# frozen_string_literal: true

require 'polipay/middleware'

module Polipay
  class Railtie < Rails::Railtie
    initializer 'polipay.use_rack_middleware' do |app|
      app.config.middleware.use Polipay::Middleware
    end
  end
end
