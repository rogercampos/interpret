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

    def interpret_title(title)
      content_for :title do
        title
      end
    end

    def interpret_parent_layout(layout)
      @view_flow.set(:layout, self.output_buffer)
      self.output_buffer = render(:file => "layouts/#{layout}")
    end

    def t(key, options = {})
      if Interpret.live_edit
        #keys = build_keys(key, options)
        #"<span class='interpret_editable' data-key='#{keys}'>#{translate(key, options)}</span>".html_safe
        translate(key, options)
      else
        translate(key, options) #.html_safe
      end
    end

    def interpret_live_edition
      return unless Interpret.live_edit
      content_tag(:div) do
        concat(javascript_include_tag "facebox-1.3/facebox")
        concat javascript_tag <<-JS
          $(document).ready(function(){
            $(".interpret_editable").click(function() {
              var key = $(this).attr("data-key");
              jQuery.facebox({ ajax: '#{live_edit_interpret_translations_path}?key=' + key});
              return false;
            });
          });
        JS
        concat(stylesheet_link_tag "interpret_live_edit_style")
        concat(stylesheet_link_tag "/javascripts/facebox-1.3/facebox.css")
      end
    end

  private
    def build_keys(key, options)
      I18n.normalize_keys(I18n.locale, scope_key_by_partial(key), options[:scope]).join(".")
    end

    def scope_key_by_partial(key)
      if key.to_s.first == "."
        #"#{@_virtual_path.gsub(%r{/_?}, ".")}#{key.to_s}"
        key
      else
        key
      end
    end

    def build_tree(hash, origin_keys = "", prev_key = "")
      out = "<ul>"
      if origin_keys.present? && prev_key.blank?
        parent_key = origin_keys.split(".")[0..-2].join(".")
        if parent_key.blank?
          out << "<li>#{link_to "..", root_path}</li>"
        else
          out << "<li>#{link_to "..", root_path(:key => parent_key)}</li>"
        end
      end
      hash.keys.each do |key|
        out << "<li>"
        out << "#{link_to key, root_path(:key => "#{origin_keys.blank? ? "" : "#{origin_keys}."}#{prev_key}#{key}")}"
        out << "</li>"
      end
      out << "</ul>"
      out.html_safe
    end
  end
end
