module Interpret
  module TranslateHelper
    def t(key, options = {})
      if true #send(Interpret.current_user) && can?(:use, :live_edit) && cookies[:"_interpret_live_edition_mode"] == "true"
        keys = key
        "<span class='interpret_live_editable' data-key='#{keys}'>#{super}</span>".html_safe
      else
        super
      end
    end
  end
end

