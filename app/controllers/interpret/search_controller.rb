class Interpret::SearchController < Interpret::BaseController

  def perform
    t = Interpret::Translation.arel_table
    @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].matches("%#{params[:key]}%").and(t[:value].matches("%#{params[:value]}%"))  )
  end
end
