if Rails.env.production?
  Rails.application.config.hosts = []
end
