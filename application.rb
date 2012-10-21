#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require :default

require 'active_support/core_ext/numeric/time'

# Load any libraries
Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require f }

# Load any initializers
Dir["#{File.dirname(__FILE__)}/config/initializers/**/*.rb"].each { |f| require f }

# Load models
Dir["#{File.dirname(__FILE__)}/models/**/*.rb"].each { |f| require f }

# Load controllers
Dir["#{File.dirname(__FILE__)}/controllers/**/*.rb"].each { |f| require f }


module Checkers
  class API < Goliath::API
    include Zhomart::Router

    use Goliath::Rack::Tracer             # log trace statistics

    use Zhomart::AssetStylus
    use Zhomart::AssetCoffee
    use Zhomart::AssetSlim
    use Rack::Static, :urls => ["/css", "/images", '/js'], :root => "public", :index => 'index.html'

    use Goliath::Rack::DefaultMimeType    # cleanup accepted media types
    use Goliath::Rack::Render, 'json'     # auto-negotiate response format
    use Goliath::Rack::Params             # parse & merge query and body parameters
    use Goliath::Rack::Heartbeat          # respond to /status with 200, OK (monitoring, etc)

    # If you are using Golaith version <=0.9.1 you need to Goliath::Rack::ValidationError
    # to prevent the request from remaining open after an error occurs
    # use Goliath::Rack::ValidationError
    # use Goliath::Rack::Validation::RequestMethod, %w(GET POST)           # allow GET and POST requests only
    # use Goliath::Rack::Validation::RequiredParam, {:key => 'action'}  # must provide ?echo= query or body param

    route "/sign_in", :sign_in
    route "/game_list", :game_list
    route "/new_game", :new_game
    route "/user_info", :user_info
    route "/get_opponent", :get_opponent
    route "/cancel_game", :cancel_game
    route "/start_game", :start_game

    attr_accessor :data

    def response(env)
      path = env['PATH_INFO'].sub(/^(.+)\/$/, '\1')

      return serve_assets(path) if path =~ /(js|stylus|css)\/.*/

      method_name = self.class.routes[path]

      return [404, {}, "#{path} not found"] if not method_name

      env['params'] = params
      env['api'] = self
      controller = GameController.new(env)

      [200, {}, controller.send(method_name)]
    end

    def self.mongo; Thread.current[GOLIATH_ENV].mongo; end;

  end
end
