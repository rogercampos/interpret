Rails.application.routes.draw do
  namespace :interpret do
    root :to => "translations#index"

    resources :translations, :except => [:index, :new, :create, :destroy] do
      collection do
        get :fetch
        post :upload
      end
    end
  end
end
