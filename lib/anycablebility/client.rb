# frozen_string_literal: true

require 'thread'
require 'json'
require 'websocket-eventmachine-client'

require 'anycablebility/waiter'

module Anycablebility
  # This is a simple ActionCable client created for testing purposes
  class Client
    attr_reader :state

    def initialize(cable_url, debug = false, ignore_message_types = [])
      @logger = Logger.new(debug ? STDOUT : IO::NULL)

      @cable_url = cable_url
      @ignore_message_types = ignore_message_types

      @state = :initial

      @inbox = Queue.new
      @send_queue = Queue.new

      run_websocket_client

      Waiter.wait(5) { @state == :welcomed }

      @logger.debug('connection is established')
    end

    def send(message)
      EventMachine.next_tick do
        @ws.send(message)
        @logger.debug("message sent: #{message}")
      end

      @logger.debug("message added to the send queue #{message}")
    end

    def receive(parsed = false)
      Waiter.wait(5) { !@inbox.empty? } if @inbox.empty?

      message = @inbox.pop

      message[parsed ? :parsed : :raw]
    end

    def receive_parsed
      receive(true)
    end

    private

    def run_websocket_client
      @thread = Thread.new do
        EventMachine.run do
          @ws = WebSocket::EventMachine::Client.connect(uri: @cable_url)

          @ws.onopen do
            @logger.debug('connected')
            @state = :connected
          end

          @ws.onmessage do |raw_message, type|
            @logger.debug("new message: #{raw_message}, type: #{type}")
            handle_message(raw_message, type)
          end

          @ws.onclose do
            raise 'Unexpectedly disconnected'
          end
        end
      end
      @thread.abort_on_exception = true
    end

    def handle_message(raw_message, type)
      parsed_message = parse_message(raw_message)

      if welcome_message?(parsed_message)
        @logger.debug('welcomed')
        @state = :welcomed
      end

      message_to_add = { raw: raw_message, parsed: parsed_message }

      @inbox << message_to_add unless ignore?(parsed_message)
    end

    def parse_message(message)
      JSON.parse(message, symbolize_names: true)
    end

    def welcome_message?(parsed_message)
      parsed_message[:type] == 'welcome'
    end

    def ignore?(parsed_message)
      return false unless parsed_message.has_key?(:type)

      type = parsed_message[:type].to_sym

      @ignore_message_types.include?(type)
    end
  end
end
