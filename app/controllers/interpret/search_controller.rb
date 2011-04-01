class Interpret::SearchController < Interpret::BaseController

  def perform
    t = Interpret::Translation.arel_table
    search_key = params[:key].split(" ").map{|x| "%#{CGI.escape(x)}%"}
    search_value = params[:value].split(" ").map{|x| "%#{CGI.escape(x)}%"}
    @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].matches_all(search_key).or(t[:value].matches_all(search_value))  )
  end
end
