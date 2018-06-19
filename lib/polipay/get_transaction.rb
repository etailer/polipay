# frozen_string_literal: true

require 'http'

module Polipay
  class GetTransaction
    Invalid = Class.new(StandardError)
    Error = Class.new(StandardError)

    def self.perform(args)
      new(args[:token]).perform
    end

    def initialize(token)
      raise Invalid, 'Token is required' if token.nil? || token.empty?
      @token = token
      @url = File.join(config.merchant_api_url, 'Transaction', 'GetTransaction')
      @username = config.merchant_code
      @password = config.authentication_code
    end

    def perform
      OpenStruct.new client
    end

  private

    def client
      response = HTTP.basic_auth(user: @username, pass: @password).headers(accept: 'application/json').get(@url, params: { token: @token })
      raise Error, response.to_s if response.code != 200
      response.parse
    end

    def config
      @config ||= Polipay.configuration
    end
  end
end
