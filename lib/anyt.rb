# frozen_string_literal: true

require "logger"
require "anyt/version"
require "anyt/config"
require "anyt/utils"

# AnyCable conformance testing tool
module Anyt
  class << self
    def config
      @config ||= Config.new
    end
  end
end
