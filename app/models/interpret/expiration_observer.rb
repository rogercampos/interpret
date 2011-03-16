module Interpret

  class ExpirationObserver < ActiveRecord::Observer
    observe Interpret::Translation

    def after_update(record)
      run_expiration if record.value_changed?
    end

    def after_create(record)
      run_expiration
    end

    def after_destroy(record)
      run_expiration
    end

  protected
    # expiration logic for your app
    def expire_cache
    end

  private
    def run_expiration
      Interpret.backend.reload! if Interpret.backend
      expire_cache
    end
  end
end
