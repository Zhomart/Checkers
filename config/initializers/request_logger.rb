class RequestLogger

  def initialize(app)
    @app = app
  end

  def call(env)
    Chess::API.logger.info "REQUEST: #{env["PATH_INFO"]}"
    @app.call env
  end
end
