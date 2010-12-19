Rails.application.routes.draw do
  resources :translations, :except => [:new, :create, :destroy, :show], :controller => Interpret.controller do
    collection do
      get :fetch
      post :upload
    end
  end
end
