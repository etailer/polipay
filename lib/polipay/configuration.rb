# frozen_string_literal: true

require 'logger'

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
      :merchant_reference_format, # https://www.polipayments.com/NZreconciliation
      :merchant_homepage_url,
      :timeout,
      :success_url,
      :failure_url,
      :cancellation_url,
      :notification_url,
      :success_path,
      :failure_path,
      :cancellation_path,
    ]

    alias_method :raise_exceptions?, :raise_exceptions

    def success_url
      @success_url ||= File.join @merchant_homepage_url, @success_path
    end

    def failure_url
      @failure_url ||= File.join @merchant_homepage_url, @failure_path
    end

    def cancellation_url
      @cancellation_url ||= File.join @merchant_homepage_url, @cancellation_path
    end

    def notification_url
      @notification_url ||= File.join @merchant_homepage_url, @mount_point
    end

    def initialize
      @mount_point = '/polipay'
      @logger = Logger.new STDOUT
      @raise_exceptions = true unless ENV['RACK_ENV'] == 'production'
      @merchant_api_url = 'https://poliapi.apac.paywithpoli.com/api/v2/'

      # no defaults are set for the below in this client
      # @merchant_code =
      # @currency_code =
      # @merchant_reference_format =
      # @timeout = 900
      # @success_path =
      # @failure_path =
      # @cancellation_path =
      # @success_url =
      # @failure_url =
      # @cancellation_url =
      # @authentication_code =
      # @merchant_homepage_url =
    end
  end
end
