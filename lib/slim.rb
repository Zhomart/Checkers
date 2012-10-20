module Zhomart

  class AssetSlim

    def initialize(app, options={})
      @app = app
      @root = File.join Dir.pwd, 'public'
    end

    def call(env)
      path = env["PATH_INFO"]

      if path =~ /slim\/(.*)\.html$/
        file_path = File.join(@root, "slim/#{$1}.slim")
        if not File.exists?(file_path)
          return [404, {"Content-Type"=>"text/html"}, ["File not found"]]
        end
        html = Slim::Template.new(file_path, {}).render
        [200,
        {"Last-Modified"=>Time.now.to_s,
          "Content-Type"=>"text/html", "Content-Length"=>html.size.to_s}, [html]]
      else
        @app.call(env)
      end
    end
  end

end
