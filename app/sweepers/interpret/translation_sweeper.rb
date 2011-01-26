class Interpret::TranslationSweeper < ActionController::Caching::Sweeper
  observe Interpret::Translation

  def after_create(translation)
    expire_cache
  end

  def after_destroy(translation)
    expire_cache
  end

private
  def expire_cache
    expire_action :controller => "interpret/translations", :action => :tree
  end
end
