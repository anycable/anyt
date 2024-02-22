# frozen_string_literal: true

require "anyt"

module Anyt
  # Synchronous websocket client
  # Based on https://github.com/rails/rails/blob/v5.0.1/actioncable/test/client_test.rb
  class Client
    require "websocket-client-simple"
    require "concurrent"

    class Error < StandardError; end

    class TimeoutError < Error; end

    class DisconnectedError < Error
      attr_reader :event

      def initialize(event)
        @event = event
        if event
          super("WebSocket disconnected (code=#{event.code}, reason=#{event.data})")
        else
          super("WebSocket disconnected abnormally")
        end
      end
    end

    WAIT_WHEN_EXPECTING_EVENT = 5
    WAIT_WHEN_NOT_EXPECTING_EVENT = 0.5

    private attr_reader :logger

    attr_reader :url

    def initialize(
      ignore: [], url: Anyt.config.target_url, qs: "",
      cookies: "", headers: {},
      protocol: "actioncable-v1-json",
      timeout_multiplier: Anyt.config.timeout_multiplier,
      logger: AnyCable.logger
    )
      @logger = logger
      ignore_message_types = @ignore_message_types = ignore
      messages = @messages = Queue.new
      closed = @closed = Concurrent::Event.new
      has_messages = @has_messages = Concurrent::Semaphore.new(0)

      @timeout_multiplier = timeout_multiplier

      headers = headers.merge("cookie" => cookies)
      headers["Sec-WebSocket-Protocol"] = protocol

      open = Concurrent::Promise.new

      @url = url

      if !qs.empty?
        @url += @url.include?("?") ? "&" : "?"
        @url += qs
      end

      @ws = WebSocket::Client::Simple.connect(
        @url,
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
          next if event.type == :ping
          if event.type == :close
            messages << DisconnectedError.new(event)
            has_messages.release
            closed.set
          else
            message = JSON.parse(event.data)

            next if ignore_message_types.include?(message["type"])

            logger.debug "Message received: #{message}"

            messages << message
            has_messages.release
          end
        end

        ws.on(:close) do |_event|
          closed.set
        end
      end

      open.wait!(WAIT_WHEN_EXPECTING_EVENT * @timeout_multiplier)
    end
    # rubocop: enable Metrics/BlockLength
    # rubocop: enable Metrics/AbcSize
    # rubocop: enable Metrics/MethodLength

    def receive(timeout: WAIT_WHEN_EXPECTING_EVENT)
      timeout *= @timeout_multiplier

      unless @has_messages.try_acquire(1, timeout)
        raise DisconnectedError if closed?
        raise TimeoutError, "Timed out to receive message"
      end

      msg = @messages.pop(true)
      raise msg if msg.is_a?(Exception) || msg.is_a?(Error)

      msg
    end

    def send(message)
      @ws.send(JSON.generate(message))
    end

    def close(allow_messages: false)
      sleep WAIT_WHEN_NOT_EXPECTING_EVENT * @timeout_multiplier

      raise "#{@messages.size} messages unprocessed" unless allow_messages || @messages.empty?

      @ws.close
      wait_for_close
    end

    def wait_for_close
      @closed.wait(WAIT_WHEN_EXPECTING_EVENT * @timeout_multiplier)
    end

    def closed?
      @closed.set?
    end
  end
end
