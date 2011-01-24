module ApplicationHelper
  def section_link_to(name, options = {}, html_options = {})
    html_options.merge!({ :class => 'current' }) if current_page?(options)
    link_to name, options, html_options
  end

  def title(page_title)
    content_for :title do
      page_title
    end
  end
end
