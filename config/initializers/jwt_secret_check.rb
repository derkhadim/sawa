Rails.application.config.after_initialize do
  unless ENV['JWT_SECRET'].present?
    raise "JWT_SECRET environment variable is not set!"
  end
end
