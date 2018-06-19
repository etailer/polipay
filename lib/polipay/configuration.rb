# frozen_string_literal: true

module Polipay
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor *[
      :logger,
      :mount_point,
      :raise_exceptions,
      :merchant_api_url,
      :merchant_code,
      :authentication_code,
      :currency_code,
      :merchant_reference_format,
      :merchant_homepage_url,
      :success_url,
      :failure_url,
      :cancellation_url,
      :timeout,
      :selected_fi_code,
    ]

    alias_method :raise_exceptions?, :raise_exceptions

    def initialize
      @mount_point = '/polipay'
      @logger = Logger.new STDOUT
      @raise_exceptions = true unless ENV['RACK_ENV'] == 'production'
      @merchant_api_uri = 'https://poliapi.apac.paywithpoli.com/api/v2/'
      # no defaults are set for the below in this client
      # @merchant_code =
      # @currency_code =
      # @merchant_reference_format =
      # @timeout = 900
      # @success_url =
      # @failure_url =
      # @cancellation_url =
      # @selected_fi_code =
      # @authentication_code =
      # @merchant_homepage_url =
    end
  end
end
