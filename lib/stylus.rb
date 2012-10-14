module Zhomart

  class AssetStylus

    def initialize(app, options={})
      @app = app
      @root = File.join Dir.pwd, 'public'
    end

    def call(env)
      path = env["PATH_INFO"]

      if path =~ /stylus\/(.*)\.css$/
        file_path = "stylus/#{$1}.styl"
        css = Stylus.compile(File.new(File.join(@root, file_path)))
        p "css"
        [200,
        {"Last-Modified"=>Time.now.to_s,
          "Content-Type"=>"text/css", "Content-Length"=>css.size.to_s}, [css]]
      else
        @app.call(env)
      end
    end
  end

end
