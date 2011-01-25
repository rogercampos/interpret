class Interpret::SearchController < ApplicationController
  layout 'interpret'

  def perform
    @translations = Interpret::Translation.where("key LIKE '%#{params[:key]}%'").where("value LIKE '%#{params[:value]}%'")

    puts @translations.inspect
  end
end
