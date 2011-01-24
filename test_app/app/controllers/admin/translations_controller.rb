class Admin::TranslationsController < Interpret::TranslationsController
  before_filter :authenticate_user!
  layout 'private'
end
