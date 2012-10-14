require File.expand_path('../boot', __FILE__)

Bundler.require :default, ENV['RACK_ENV']

# Load any libraries
Dir["#{File.dirname(__FILE__)}/../lib/**/*.rb"].each { |f| require f }

# Load any initializers
Dir["#{File.dirname(__FILE__)}/initializers/**/*.rb"].each { |f| require f }

# Load models
Dir["#{File.dirname(__FILE__)}/../models/**/*.rb"].each { |f| require f }

# Load apis
Dir["#{File.dirname(__FILE__)}/../api/**/*.rb"].each { |f| require f }

# require File.expand_path('../../api/api', __FILE__)

Mongoid.logger = Moped.logger = Chess::API.logger

Mongoid.logger.level = Moped.logger.level = Logger::DEBUG
