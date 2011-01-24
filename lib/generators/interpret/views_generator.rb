module Interpret

  class ViewsGenerator < Rails::Generators::Base
    source_root File.expand_path("../../../../app/views", __FILE__)
    desc "Copies all Interpret views to your application."

    argument :scope, :required => false, :default => nil,
                      :desc => "The scope to copy views to"

    def copy_views
      scope ||=  Interpret.controller.split("/").first
      directory "interpret", "app/views/#{scope}"
    end

  end
end
