Rails.application.routes.draw do
  scope Interpret.scope do
    namespace :interpret do
      resources :translations, :only => [:destroy, :edit, :update, :create] do
        collection do
          get :live_edit
        end
      end

      resources :tools, :only => :index do
        collection do
          get :export
          post :import
          post :dump
          post :run_update
        end
      end

      match "search", :to => "search#index"
      resources :missing_translations
      match "blank", :to => "missing_translations#blank", :as => "blank_translations"
      match "unused", :to => "missing_translations#unused", :as => "unused_translations"
      match "stale", :to => "missing_translations#stale", :as => "stale_translations"

      root :to => "translations#index"
    end
  end
end
