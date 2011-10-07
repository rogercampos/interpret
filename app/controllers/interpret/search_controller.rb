class Interpret::SearchController < Interpret::BaseController
  def index
    if request.post?
      opts = {}
      opts[:key] = params[:key] if params[:key].present?
      opts[:value] = params[:value] if params[:value].present?
      redirect_to interpret_search_url(opts)
    else
      if params[:key].present? || params[:value].present?
        t = Interpret::Translation.arel_table
        search_key = params[:key].present? ? params[:key].split(" ").map{|x| "%#{CGI.escape(x)}%"} : []
        search_value = params[:value].present? ? params[:value].split(" ").map{|x| "%#{CGI.escape(x)}%"} : []
        @translations = Interpret::Translation.locale(I18n.locale).where(t[:key].matches_all(search_key).or(t[:value].matches_all(search_value))).order("translations.key ASC")
      end
    end
  end
end
