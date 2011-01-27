class Interpret::SearchController < eval("#{Interpret.controller.classify}Controller")
  layout 'interpret'

  def perform
    @translations = Interpret::Translation.where("key LIKE '%#{params[:key]}%'").where("value LIKE '%#{params[:value]}%'")
  end
end
