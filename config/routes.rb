Rails.application.routes.draw do
  scope Interpret.scope do
    namespace :interpret do
      resources :translations, :except => [:index, :new, :create, :destroy, :show]  do
        collection do
          get :node
        end
      end

      resources :tools, :only => :index do
        collection do
          get :fetch
          post :upload
          post :migrate
        end
      end

      match "search", :to => "search#index"
      match "search_for", :to => "search#perform"

      root :to => "translations#index"
    end
  end
end
