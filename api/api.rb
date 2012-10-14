module Chess
  class API < Grape::API
    version 'v1', :using => :path, :vendor => 'chess'
    format :json

    use RequestLogger

    helpers do
      include ApiHelpers
    end

    # rescue_from :all do |e|
    #   Rack::Response.new([ e.message ], 500, { "Content-type" => "text/error" }).finish
    # end

    # just for testing
    resources :games do
      get 'new_game' do
        "new game".to_json
      end
    end

    resources :users do

      get 'current_user' do
        "cur user".to_json
      end

    end
  end
end
