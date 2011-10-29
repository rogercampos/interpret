class Interpret::SearchController < Interpret::BaseController
  before_filter { authorize! :use, :search }

  def index
    if request.post?
      opts = {}
      opts[:key] = params[:key] if params[:key].present?
      opts[:value] = params[:value] if params[:value].present?
      redirect_to interpret_search_url(opts)
    else
      if params[:key].present? || params[:value].present?
        sanitizer = case ActiveRecord::Base.connection.adapter_name
                    when "SQLite"
                      if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new("1.9")
                        lambda {|x| "%#{x}%"}
                      else
                        lambda {|x| "%#{CGI.escape(x)}%"}
                      end
                    else
                      lambda {|x| "%#{CGI.escape(x)}%"}
                    end
        t = Interpret::Translation.arel_table
        search_key = params[:key].present? ? params[:key].split(" ").map{|x| sanitizer.call(x)} : []
        search_value = params[:value].present? ? params[:value].split(" ").map{|x| sanitizer.call(x)} : []
        @translations = Interpret::Translation.allowed.locale(I18n.locale).where(t[:key].matches_all(search_key).or(t[:value].matches_all(search_value))).order("translations.key ASC")
      end
    end
  end
end
