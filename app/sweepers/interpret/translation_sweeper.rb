class Interpret::TranslationSweeper < ActionController::Caching::Sweeper
  observe Interpret::Translation

  def after_update(translation)
    Interpret.backend.reload! if Interpret.backend
  end

private
  def expire_cache
    #expire_action :controller => "interpret/translations", :action => :tree
    session.delete(:tree)
    Interpret.backend.reload! if Interpret.backend
  end
end
