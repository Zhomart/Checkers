require File.expand_path('../config/environment', __FILE__)

use Rack::Static, :urls => ["/css", '/images'], :root => 'public', :index => 'public/index.html'

use Rack::Logger

# use Rack::Session::Cookie, :secret => "iq35vq#$VQ#%VERsfaaw35v34afSDFSdf"

run Chess::API
