# frozen_string_literal: true

require 'polipay/version'
require 'polipay/configuration'
require 'polipay/listeners'
require 'polipay/railtie' if defined?(Rails::Railtie)

Polipay::InvalidNudge = Class.new(StandardError)
