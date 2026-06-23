Rails.application.config.hosts = []

Rails.application.config.host_authorization = { exclude: ->(request) { true } }
