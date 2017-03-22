# frozen_string_literal: true

require 'anycablebility/version'
require 'anycablebility/logging'

# Anycable conformance testing tool
module Anycablebility
  class << self
    attr_accessor :logger
  end
end
