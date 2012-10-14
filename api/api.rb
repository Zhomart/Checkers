module Sparkting
  class API < Grape::API
    version 'v1', :using => :path, :vendor => 'sparkting'
    format :json

    use RequestLogger

    helpers do
      include ApiHelpers
    end

    include EM::Deferrable

    # rescue_from :all do |e|
    #   Rack::Response.new([ e.message ], 500, { "Content-type" => "text/error" }).finish
    # end

    # just for testing
    resources :games do
      get 'new_game' do
        # redis = Redis.new(:host => "127.0.0.1", :port => 6379)
        # key = (redis.get("mykey") || 0).to_i
        # redis.set("mykey", key + 1)

        # x = EM.synchrony do
        #   # update_ads ads_hash, invalid_ads, ip, params, user_agent, request
        #   EM::Synchrony::FiberIterator.new([1,2,3]).each do |i|
        #     print "ololo #{i}\n"
        #     sleep 2
        #   end
        #   print "ololo in sync"
        #    "1".to_json
        # end

        op = proc {
          print "op op Gangan Style\n"
          "in op"
        }

        cb = proc {|result|
          print "cb cb: #{result}\n"
          " in cb "
        }

        EM.defer(op, cb)

        "new game".to_json
      end
    end

    resources :users do

      get 'current_user' do
        current_user.to_json
      end

    end
  end
end
