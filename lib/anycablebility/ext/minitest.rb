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
  def scenario desc, &block
    block ||= proc { skip "(no tests defined)" }

    define_method "test_ #{desc}", &block

    desc
  end
end

# Patch Spec reporter
module Anycablebility
  module ReporterPatch

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
