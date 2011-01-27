Rails.application.routes.draw do
  scope Interpret.scope do
    #match "/", :to => "#{Interpret.controller}#index"

    resources :translations, :except => [:new, :create, :destroy, :show], :controller => "interpret/translations", :as => Interpret.resource_name do
      collection do
        get :fetch
        post :upload
        get :node
        get :tree
        post :migrate
      end
    end

    match "tools", :to => "interpret/tools#index", :as => "interpret_tools"
    match "search", :to => "interpret/search#index", :as => "interpret_search"
    match "search_for", :to => "interpret/search#perform", :as => "interpret_search_for"
  end
end
