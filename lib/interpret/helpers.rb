module Interpret
  module InterpretHelpers

    def show_interpret_tree(hash, params_key, prev_key = "", matching_node = false)
      out = "<ul>"
      if params_key
        params_key = params_key.split(".")
        first_key = params_key.shift
        params_key = params_key.join(".")
      end
      hash.keys.each do |key|
        expandable = hash[key].present? && hash[key].is_a?(Hash)
        matching = (params_key && key == first_key && (prev_key == "" ? true : matching_node))

        opts = []
        opts << "current" if matching
        opts << "expandable" if expandable

        out << "<li#{opts.any? ? " class='#{opts.join(" ")}'" : ""}>"
        out << "#{link_to key, interpret_root_path(:key => "#{prev_key}#{key}")}"

        out << show_interpret_tree(hash[key], params_key, "#{prev_key}#{key}.", matching) if expandable
        out << "</li>"
      end
      out << "</ul>"
      out.html_safe
    end

    def current_controller?(opts)
      hash = Rails.application.routes.recognize_path(url_for(opts))
      params[:controller] == hash[:controller]
    end

    def interpret_section_link_to(name, options = {}, html_options = {})
      html_options.merge!({ :class => 'current' }) if current_controller?(options)
      link_to name, options, html_options
    end

  end
end
