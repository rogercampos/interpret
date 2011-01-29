class Interpret::SearchController < eval(Interpret.controller.classify)
  layout 'interpret'

  def perform
    t = Interpret::Translation.arel_table
    @translations = Interpret::Translation.where(t[:key].matches("%#{params[:key]}%").and(t[:value].matches("%#{params[:value]}%"))  )
  end
end
