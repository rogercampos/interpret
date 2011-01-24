module ApplicationHelper
  def show_tree(hash, params_key, prev_key = "")
    out = "<ul>"
    if params_key
      params_key = params_key.split(".")
      first_key = params_key.shift
      params_key = params_key.join(".")
    end
    hash.keys.each do |key|
      out += "<li>"
      out += "<b>" if params_key && key == first_key
      out += "#{link_to key, node_translations_path(:key => prev_key+key)}"
      out += "</b>" if params_key && key == first_key

      if hash[key].present? && hash[key].is_a?(Hash)
        out += show_tree(hash[key], params_key, "#{prev_key}#{key}.")
      end
      out += "</li>"
    end
    out += "</ul>"
    out.html_safe
  end
end
