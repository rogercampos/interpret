module ApplicationHelper
  def show_tree(hash, prev_key = "")
    out = "<ul>"
    hash.keys.each do |key|
      out += "<li>#{link_to key, node_translations_path(:key => prev_key+key)}"
      if hash[key].present? && hash[key].is_a?(Hash)
        out += show_tree(hash[key], "#{prev_key}#{key}.")
      end
      out += "</li>"
    end
    out += "</ul>"
    out.html_safe
  end
end
