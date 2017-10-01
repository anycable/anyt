# frozen_string_literal: true

require "minitest/spec"
require "minitest/reporters"

module Anycablebility
  # Common tests helpers
  module TestHelpers
    def self.included(base)
      base.let(:client) { build_client(ignore: %w[ping welcome]) }
    end

    def build_client(*args)
      Anycablebility::Client.new(*args)
    end
  end
end

module Anycablebility
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
          connection.params['test'] == tag
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
    cls.include Anycablebility::TestHelpers
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
    class_name = @name.gsub(/\s+/, '_')
    class_name += "_#{id}" if id
    class_name += "_channel"

    cls = Class.new(ApplicationCable::Channel, &block)

    Anycablebility::TestChannels.const_set(class_name.classify, cls)

    helper_name = id ? "#{id}_channel" : "channel"

    let(helper_name) { cls.name }
  end

  # Add new #connect handler
  def connect_handler(tag, &block)
    Anycablebility::ConnectHandlers.add(tag, &block)
  end
end

module Anycablebility
  # Patch Minitest load_plugins to disable Rails plugin
  # See: https://github.com/kern/minitest-reporters/issues/230
  module MinitestPatch
    def load_plugins
      super
      extensions.delete('rails')
    end
  end

  # Patch Spec reporter
  module ReporterPatch # :nodoc:
    def record_print_status(test)
      test_name = test.name.gsub(/^test_/, '').strip
      print pad_test(test_name)
      print_colored_status(test)
      print(" (%.2fs)" % test.time) unless test.time.nil?
      puts
    end
  end
end

Minitest::Reporters::SpecReporter.prepend Anycablebility::ReporterPatch
Minitest.singleton_class.prepend Anycablebility::MinitestPatch
