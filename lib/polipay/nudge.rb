# frozen_string_literal: true

module Polipay
  class Nudge
    Invalid = Class.new(StandardError)

    attr_reader :token

    def initialize(opts = {})
      raise Invalid, 'Token is not present' if opts['Token'].nil? || opts['Token'].empty?

      @token = opts['Token']
    end
  end
end
