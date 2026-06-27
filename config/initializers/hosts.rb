Rails.application.config.hosts = [
  'sawa-production-41b3.up.railway.app',
  'localhost',
  ENV.fetch('APP_HOST', nil)
].compact
