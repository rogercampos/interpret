class Interpret::TranslationSweeper < ActionController::Caching::Sweeper
  observe Interpret::Translation

  def after_update(translation)
    Interpret.backend.reload! if Interpret.backend
  end

  def after_create(translation)
    Interpret.backend.reload! if Interpret.backend
  end
end
