# frozen_string_literal: true

require 'http'

module Polipay
  class InitiateTransaction
    Invalid = Class.new(StandardError)

    def self.perform(amount:, merchant_reference:, merchant_data: '', selected_fi_code: '')
      new(amount: amount, merchant_reference: merchant_reference, merchant_data: merchant_data, selected_fi_code: selected_fi_code).perform
    end

    def initialize(opts)
      @amount = opts[:amount]
      @merchant_reference = opts[:merchant_reference]
      @merchant_data = opts[:merchant_data]
      @selected_fi_code = opts[:selected_fi_code]
      @url = File.join(config.merchant_api_url, 'Transaction', 'Initiate')
      @username = config.merchant_code
      @password = config.authentication_code
    end

    def perform
      OpenStruct.new client.parse
    end

  private

    def client
      HTTP.basic_auth(user: @username, pass: @password).headers(content_type: 'application/json').post(@url, json: payload)
    end

    def payload
      {
        Amount: '%.2f' % @amount,
        CurrencyCode: config.currency_code,
        MerchantReference: @merchant_reference,
        MerchantReferenceFormat: config.merchant_reference_format,
        MerchantData: @merchant_data,
        MerchantHomepageURL: config.merchant_homepage_url,
        SuccessURL: config.success_url,
        FailureURL: config.failure_url,
        CancellationURL: config.cancellation_url,
        NotificationURL: config.notification_url,
        Timeout: config.timeout,
        SelectedFICode: @selected_fi_code,
      }.delete_if { |k, v| v.nil? || v.empty? }
    end

    def config
      @config ||= Polipay.configuration
    end
  end
end
