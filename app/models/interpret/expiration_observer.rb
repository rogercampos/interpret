module Interpret

  class ExpirationObserver < ActiveRecord::Observer
    observe Interpret::Translation

    def after_update(record)
      run_expiration(record) if record.value_changed?
    end

    def after_create(record)
      run_expiration(record)
    end

    def after_destroy(record)
      run_expiration(record)
    end

  protected
    # expiration logic for your app
    def expire_cache(key)
    end

  private
    def run_expiration(record)
      Interpret.backend.reload! if Interpret.backend
      expire_cache(record.key)
    end
  end
end
