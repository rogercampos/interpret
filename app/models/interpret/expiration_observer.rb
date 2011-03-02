module Interpret
  class ExpirationObserver < ActiveRecord::Observer
    observe Interpret::Translation

    def after_update(record)
      run_expiration
    end

    def after_create(record)
      run_expiration
    end

    def after_destroy(record)
      run_expiration
    end

  protected
    def expire_cache
      #puts "EXPIRATED!"
    end

  private
    def run_expiration
      Interpret.backend.reload! if Interpret.backend
      expire_cache
    end
  end
end
