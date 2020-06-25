# frozen_string_literal: true

ENV["TERM"] = "#{ENV["TERM"]}color" unless ENV["TERM"]&.match?(/color/)
require "minitest/spec"
require "minitest/reporters"

module Anyt
  # Common tests helpers
  module TestHelpers
    def self.included(base)
      base.let(:client) { @client = build_client(ignore: %w[ping welcome]) }
      base.after { @client&.close(allow_messages: true) }
    end

    def build_client(*args)
      Anyt::Client.new(*args)
    end

    def restart_server!
      if Anyt.config.use_action_cable
        remote_client.restart_action_cable
      else
        Command.restart
      end
    end

    def remote_client
      @remote_client ||= RemoteControl::Client.connect(Anyt.config.remote_control_port)
    end
  end
end

module Anyt
  # Namespace for test channels
  module TestChannels; end

  # Custom #connect handlers management
  module ConnectHandlers
    class << self
      def call(connection)
        handlers_for(connection).each do |(_, handler)|
          connection.reject_unauthorized_connection unless
            connection.instance_eval(&handler)
        end
      end

      def add(tag, &block)
        handlers << [tag, block]
      end

      private

      def handlers_for(connection)
        handlers.select do |(tag, _)|
          connection.params["test"] == tag
        end
      end

      def handlers
        @handlers ||= []
      end
    end
  end
end

# Kernel extensions
module Kernel
  ## Wraps `describe` and include shared helpers
  private def feature(*args, &block)
    cls = describe(*args, &block)
    cls.include Anyt::TestHelpers
    cls
  end
end

# Extend Minitest Spec DSL with custom methodss
module Minitest::Spec::DSL
  # Simplified version of `it` which doesn't care
  # about unique method names
  def scenario(desc, &block)
    block ||= proc { skip "(no tests defined)" }

    define_method "test_ #{desc}", &block

    desc
  end

  # Generates Channel class dynamically and
  # add memoized helper to access its name
  def channel(id = nil, &block)
    class_name = @name.gsub(/\s+/, "_")
    class_name += "_#{id}" if id
    class_name += "_channel"

    cls = Class.new(ApplicationCable::Channel, &block)

    Anyt::TestChannels.const_set(class_name.classify, cls)

    helper_name = id ? "#{id}_channel" : "channel"

    let(helper_name) { cls.name }
  end

  # Add new #connect handler
  def connect_handler(tag, &block)
    Anyt::ConnectHandlers.add(tag, &block)
  end
end

module Anyt
  # Patch Minitest load_plugins to disable Rails plugin
  # See: https://github.com/kern/minitest-reporters/issues/230
  module MinitestPatch
    def load_plugins
      super
      extensions.delete("rails")
    end
  end

  # Patch Spec reporter
  module ReporterPatch # :nodoc:
    def record_print_status(test)
      test_name = test.name.gsub(/^test_/, "").strip
      print(magenta { pad_test(test_name) })
      print_colored_status(test)
      print(" (%.2fs)" % test.time) unless test.time.nil?
      puts
    end
  end
end

Minitest::Reporters::SpecReporter.prepend Anyt::ReporterPatch
Minitest.singleton_class.prepend Anyt::MinitestPatch
