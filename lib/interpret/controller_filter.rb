class ActionController::Base
  before_filter :set_interpret_user

  private
    def set_interpret_user
      return unless Interpret.live_edit

      if Interpret.current_user && defined?(Interpret.current_user.to_sym)
        @interpret_user = eval(Interpret.current_user)
      end
    end
end
