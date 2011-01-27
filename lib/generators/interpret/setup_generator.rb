module Interpret

  class SetupGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../../public", __FILE__)
    desc "Copies needed css and js files into your app's public folders"

    def copy_css
      copy_file "stylesheets/interpret_style.css", "public/stylesheets/interpret_style.css"
    end

    def copy_js
      copy_file "javascripts/jquery.purr.js", "public/javascripts/jquery.purr.js"
    end

    def copy_images
      copy_file "stylesheets/plus_icon.gif", "public/stylesheets/plus_icon.gif"
      copy_file "stylesheets/minus_icon.gif", "public/stylesheets/minus_icon.gif"

    end
  end
end
