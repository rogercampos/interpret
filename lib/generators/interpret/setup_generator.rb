module Interpret

  class SetupGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../../public", __FILE__)
    desc "Copies needed css and js files into your app's public folders"

    def copy_css
      copy_file "stylesheets/interpret_style.css", "public/stylesheets/interpret_style.css"
    end

    def copy_js
      copy_file "javascripts/interpret.js", "public/javascripts/interpret.js"
      directory "javascripts/facebox-1.3", "public/javascripts/facebox-1.3"
    end

    def copy_images
      copy_file "stylesheets/folder.png", "public/stylesheets/folder.png"
    end
  end
end
