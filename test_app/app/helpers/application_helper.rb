module ApplicationHelper
  def show_tree(hash)
    out = "<ul>"
    hash.keys.each do |key|
      out += "<li>#{key}"
      if hash[key].present? && hash[key].is_a?(Hash)
        out += show_tree(hash[key])
      end
      out += "</li>"
    end
    out += "</ul>"
    out.html_safe
  end
end
