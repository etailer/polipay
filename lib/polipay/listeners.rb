# frozen_string_literal: true

module Polipay
  LISTENERS = Array.new

  def self.on_nudge(&block)
    LISTENERS << block
  end

  def self.propagate(nudge)
    LISTENERS.each { |block| block.call nudge }
  end
end
