class Rack::Attack
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  throttle('logins/ip', limit: 5, period: 60) do |req|
    if (req.path == '/login' && req.post?) || req.path == '/api/v1/auth/login'
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
