require 'active_support/core_ext/integer/time'

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  config.force_ssl = true
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch('RAILS_LOG_LEVEL', 'info')

  config.active_record.dump_schema_after_migration = false

  config.secret_key_base = ENV['SECRET_KEY_BASE']

  config.hosts << "sawa-production-41b3.up.railway.app"
  config.hosts << /.*\.up\.railway\.app/
end
