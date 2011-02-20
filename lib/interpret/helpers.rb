module Interpret
  module InterpretHelpers

    # Generates the html tree from the given keys
    def interpret_show_tree(tree, origin_keys)
      tree = tree.first[1]
      unless origin_keys.nil?
        origin_keys.split(".").each do |key|
          tree = tree[key]
        end
      end
      build_tree(tree, origin_keys)
    end

    def interpret_section_link_to(name, options = {}, html_options = {})
      html_options.merge!({ :class => 'current' }) if current_controller?(options)
      link_to name, options, html_options
    end

    def interpret_title(title)
      content_for :title do
        title
      end
    end

  private
    def build_tree(hash, origin_keys = "", prev_key = "")
      out = "<ul>"
      if origin_keys.present? && prev_key.blank?
        parent_key = origin_keys.split(".")[0..-2].join(".")
        if parent_key.blank?
          out << "<li>#{link_to "..", interpret_root_path}</li>"
        else
          out << "<li>#{link_to "..", interpret_root_path(:key => parent_key)}</li>"
        end
      end
      hash.keys.each do |key|
        out << "<li>"
        out << "#{link_to key, interpret_root_path(:key => "#{origin_keys.blank? ? "" : "#{origin_keys}."}#{prev_key}#{key}")}"
        out << "</li>"
      end
      out << "</ul>"
      out.html_safe
    end

    def current_controller?(opts)
      hash = Rails.application.routes.recognize_path(url_for(opts))
      params[:controller] == hash[:controller]
    end
  end
end
