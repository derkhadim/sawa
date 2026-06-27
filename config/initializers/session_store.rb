Rails.application.config.session_store :cookie_store,
  key: '_sawa_session',
  secure: Rails.env.production?,
  httponly: true,
  same_site: :lax,
  expire_after: 8.hours
