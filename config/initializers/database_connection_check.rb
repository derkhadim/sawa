# Database connection retry on boot.
# This helps when the database server is still starting up (common on Railway).
# The app will wait and retry the connection before fully booting.
if Rails.env.production?
  Rails.application.config.after_initialize do
    max_retries = ENV.fetch('DB_BOOT_RETRIES', '60').to_i
    retry_delay = ENV.fetch('DB_BOOT_RETRY_DELAY', '2').to_f

    pg_errors = defined?(PG) ? [PG::ConnectionBad, PG::ServerError, PG::UnableToSend] : []
    rescue_classes = [ActiveRecord::ConnectionNotEstablished, *pg_errors]

    attempts = 0
    begin
      ActiveRecord::Base.connection
      rescue ActiveRecord::ConnectionNotEstablished, *pg_errors => e
      attempts += 1
      if attempts <= max_retries
        Rails.logger.warn("[db] Base de donnees non prete (#{e.class}). Nouvelle tentative #{attempts}/#{max_retries} dans #{retry_delay}s...")
        sleep retry_delay
        retry
      else
        Rails.logger.error("[db] Base de donnees toujours indisponible apres #{max_retries} tentatives.")
        raise
      end
    end
    Rails.logger.info('[db] Connexion a la base de donnees verifiee avec succes.')
  end
end
