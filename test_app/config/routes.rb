InterpretApp::Application.routes.draw do
  devise_for :users, :controllers => {:sessions => 'user_sessions'}

  match 'contact', :to => "static#contact"
  match 'gallery', :to => "static#gallery"

  match 'admin', :to => "admin/translations#index"
  root :to => "static#index"
end
