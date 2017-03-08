# frozen_string_literal: true

require 'anycablebility/client'

module Anycablebility
  # A factory that holds some common state to make tests less verbose
  class ClientFactory
    def initialize(cable_url, debug)
      @cable_url = cable_url
      @debug = debug
    end

    def build(*ignore_message_types)
      Client.new(@cable_url, @debug, ignore_message_types)
    end
  end
end
