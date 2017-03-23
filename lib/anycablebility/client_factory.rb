# frozen_string_literal: true

require 'anycablebility/client'

module Anycablebility
  # A factory that holds some common state to make tests less verbose
  class ClientFactory
    def initialize(cable_url)
      @cable_url = cable_url
    end

    def build(*ignore_message_types)
      Client.new(@cable_url, ignore_message_types)
    end
  end
end
