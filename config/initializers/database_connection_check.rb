if Rails.env.production?
  Rails.application.config.after_initialize do
    max_retries = ENV.fetch('DB_BOOT_RETRIES', '30').to_i
    retry_delay = ENV.fetch('DB_BOOT_RETRY_DELAY', '2').to_f

    attempts = 0
    begin
      ActiveRecord::Base.connection_pool.with_connection do |conn|
        conn.execute('SELECT 1')
      end
    rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad, PG::ServerError => e
      attempts += 1
      if attempts <= max_retries
        Rails.logger.warn("[db] Base de données non prête (#{e.message}). Nouvelle tentative #{attempts}/#{max_retries}...")
        sleep retry_delay
        retry
      else
        Rails.logger.error("[db] Base de données toujours indisponible après #{max_retries} tentatives.")
        raise
      end
    end
    Rails.logger.info('[db] Connexion à la base de données vérifiée avec succès.')
  end
end
