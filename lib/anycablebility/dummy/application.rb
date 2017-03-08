# frozen_string_literal: true

require 'rails'

module Dummy
  class Application < Rails::Application
    config.time_zone = 'Moscow'
    config.eager_load = true
  end
end

Rails.application.initialize!
