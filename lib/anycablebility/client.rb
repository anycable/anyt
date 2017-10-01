# frozen_string_literal: true

module Anycablebility
  # Synchronous websocket client
  # Based on https://github.com/rails/rails/blob/v5.0.1/actioncable/test/client_test.rb
  class Client
    require "websocket-client-simple"
    require "concurrent"

    class TimeoutError < StandardError; end

    WAIT_WHEN_EXPECTING_EVENT = 5
    WAIT_WHEN_NOT_EXPECTING_EVENT = 0.5

    # rubocop: disable Metrics/AbcSize
    # rubocop: disable Metrics/MethodLength
    def initialize(
      ignore: [], url: Anycablebility.config.target_url, qs: "",
      cookies: "", headers: {}
    )
      ignore_message_types = @ignore_message_types = ignore
      messages = @messages = Queue.new
      closed = @closed = Concurrent::Event.new
      has_messages = @has_messages = Concurrent::Semaphore.new(0)

      headers = headers.merge('cookie' => cookies)

      open = Concurrent::Promise.new

      @ws = WebSocket::Client::Simple.connect(
        url + "?#{qs}",
        headers: headers
      ) do |ws|
        ws.on(:error) do |event|
          event = RuntimeError.new(event.message) unless event.is_a?(Exception)

          if open.pending?
            open.fail(event)
          else
            messages << event
            has_messages.release
          end
        end

        ws.on(:open) do |_event|
          open.set(true)
        end

        ws.on(:message) do |event|
          if event.type == :close
            closed.set
          else
            message = JSON.parse(event.data)

            next if ignore_message_types.include?(message["type"])
            messages << message
            has_messages.release
          end
        end

        ws.on(:close) do |_event|
          closed.set
        end
      end

      open.wait!(WAIT_WHEN_EXPECTING_EVENT)
    end
    # rubocop: enable Metrics/AbcSize
    # rubocop: enable Metrics/MethodLength

    def receive(timeout: WAIT_WHEN_EXPECTING_EVENT)
      raise TimeoutError, "Timed out to receive message" unless
        @has_messages.try_acquire(1, timeout)

      msg = @messages.pop(true)
      raise msg if msg.is_a?(Exception)

      msg
    end

    def send(message)
      @ws.send(JSON.generate(message))
    end

    def close
      sleep WAIT_WHEN_NOT_EXPECTING_EVENT

      raise "#{@messages.size} messages unprocessed" unless @messages.empty?

      @ws.close
      wait_for_close
    end

    def wait_for_close
      @closed.wait(WAIT_WHEN_EXPECTING_EVENT)
    end

    def closed?
      @closed.set?
    end
  end
end
