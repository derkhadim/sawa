class DbErrorMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActiveRecord::ConnectionNotEstablished, PG::ConnectionBad, PG::ServerError, PG::UnableToSend => e
    if Rails.env.production?
      [
        503,
        { 'Content-Type' => 'text/html', 'Cache-Control' => 'no-cache' },
        [File.read(Rails.root.join('app', 'views', 'layouts', 'db_error.html.erb'))]
      ]
    else
      raise e
    end
  end
end
