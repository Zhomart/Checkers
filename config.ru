require File.expand_path('../config/environment', __FILE__)

use Zhomart::AssetStylus

use Rack::Static, :urls => ["/css", '/images', '/js'], :root => 'public', :index => 'index.html'

use Rack::Logger

# use Rack::Session::Cookie, :secret => "iq35vq#$VQ#%VERsfaaw35v34afSDFSdf"

run Chess::API
