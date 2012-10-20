class Controller

  attr_reader :env

  def params; env.params; end

  def api; env['api']; end

  def api_data; api.data ||= {}; end

  def initialize(env)
    @env = env
  end

end
