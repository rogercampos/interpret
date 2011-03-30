class ActionController::Base
  before_filter :set_interpret_user

  private
    def set_interpret_user
      return unless Interpret.live_edit

      if Interpret.current_user && defined?(Interpret.current_user.to_sym)
        @interpret_user = eval(Interpret.current_user)
        @interpret_admin = true
        if Interpret.admin && @interpret_user.respond_to?(Interpret.admin)
          @interpret_admin = @interpret_user.send(Interpret.admin)
        end
      end
    end
end
