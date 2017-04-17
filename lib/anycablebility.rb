# frozen_string_literal: true

require "anycablebility/version"
require "anycablebility/config"
require "anycablebility/utils"

# Anycable conformance testing tool
module Anycablebility
  class << self
    def config
      @config ||= Config.new
    end
  end
end
