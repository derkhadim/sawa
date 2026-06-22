require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'action_mailer/railtie'
require 'active_job/railtie'
require 'rails/test_unit/railtie'


Bundler.require(*Rails.groups)

module Loca
  class Application < Rails::Application
    config.load_defaults 7.0
    config.api_only = false
    config.i18n.default_locale = :fr

    config.autoload_paths << Rails.root.join('app', 'serializers')
    config.autoload_paths << Rails.root.join('app', 'services')

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          expose: ['Authorization']
      end
    end
  end
end
