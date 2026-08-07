Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # En production, fixer CORS_ORIGINS dans Railway à l'origine exacte de l'app.
    # Par défaut : uniquement le domaine de production + localhost pour le dev.
    origins ENV.fetch('CORS_ORIGINS', 'https://sawa-production-41b3.up.railway.app,http://localhost:3000,http://127.0.0.1:3000').split(',')
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization']
  end
end
