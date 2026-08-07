class Rack::Attack
  # Store partagé si Redis est configuré, sinon store mémoire par instance.
  if ENV['REDIS_URL'].present? && defined?(ActiveSupport::Cache::RedisCacheStore) && Gem.loaded_specs.key?('redis')
    Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])
  else
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  # Login web
  throttle('logins/ip', limit: 5, period: 60) do |req|
    if req.path == '/login' && req.post?
      req.ip
    end
  end

  # Login API — limité par IP
  throttle('api/login/ip', limit: 10, period: 60) do |req|
    if req.path == '/api/v1/auth/login' && req.post?
      req.ip
    end
  end

  # Login API — limité par téléphone (brute force par compte)
  throttle('api/login/phone', limit: 5, period: 300) do |req|
    if req.path == '/api/v1/auth/login' && req.post?
      params = req.params['phone'].to_s
      params.presence && "login:#{params}"
    end
  end

  # Inscription API
  throttle('api/register/ip', limit: 3, period: 3600) do |req|
    if req.path == '/api/v1/auth/register' && req.post?
      req.ip
    end
  end

  throttle('api/ip', limit: 300, period: 60) do |req|
    if req.path.start_with?('/api/')
      req.ip
    end
  end
end

Rack::Attack.throttled_responder = lambda do |req|
  headers = {
    'Retry-After' => req.env['rack.attack.match_data']&.dig(:period)&.to_s,
    'Content-Type' => 'application/json'
  }
  [429, headers, [{ error: 'Trop de requêtes. Réessayez plus tard.' }.to_json]]
end
