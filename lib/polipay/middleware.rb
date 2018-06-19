# frozen_string_literal: true

require 'polipay/configuration'
require 'polipay/listeners'

module Polipay
  class Middleware
    def initialize(app = nil)
      @app = app
    end

    def config
      Polipay.configuration
    end

    def call(env)
      req = Rack::Request.new(env)
      return @app.call(env) unless req.path_info == config.mount_point
      return response 405 unless req.post?

      parse_and_respond req.POST
    end

  private

    def parse_and_respond(body)
      raise Polipay::InvalidNudge unless body['token'].present?

      Polipay.propagate body['token']
      response 200
    rescue Polipay::InvalidNudge => e
      config.logger.error e
      response 400, 'Invalid Nudge'
    rescue => e
      raise e if config.raise_exceptions?
      response 500
    end

    def response(status, body = '', headers = {})
      [
        status,
        { 'Content-Type' => 'text/plain' }.merge(headers),
        [body],
      ]
    end
  end
end
