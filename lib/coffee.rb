module Zhomart

  class AssetCoffee

    def initialize(app, options={})
      @app = app
      @root = File.join Dir.pwd, 'public'
    end

    def call(env)
      path = env["PATH_INFO"]

      if path =~ /coffee\/(.*)\.js$/
        file_path = "coffee/#{$1}.coffee"
        js = CoffeeScript.compile File.read(File.join(@root, file_path))

        [200, {
          "Last-Modified"=>Time.now.to_s,
          "Content-Type"=>"text/javascript",
          "Content-Length"=>js.size.to_s
          }, [js]]
      else
        @app.call(env)
      end
    end
  end

end
