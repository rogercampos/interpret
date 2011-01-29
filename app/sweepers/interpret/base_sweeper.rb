class Interpret::BaseSweeper < ActionController::Caching::Sweeper
  observe Interpret::Translation

  def after_update(translation)
    expire_cache(translation)
  end

protected

  # Implement user's custom expire logic
  def expire_cache(translation)
  end
end

