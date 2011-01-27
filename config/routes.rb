Rails.application.routes.draw do
  namespace :interpret do
    resources :translations, :except => [:new, :create, :destroy, :show]  do
      collection do
        get :node
        get :tree
      end
    end

    resources :tools, :only => :index do
      collection do
        get :fetch
        post :upload
        post :migrate
      end
    end

    #match "tools", :to => "interpret/tools#index", :as => "interpret_tools"
    match "search", :to => "search#index"
    match "search_for", :to => "search#perform"
  end
  #scope Interpret.scope do
    #resources :translations, :except => [:new, :create, :destroy, :show], :controller => "interpret/translations", :as => Interpret.resource_name do
      #collection do
        #get :node
        #get :tree
      #end
    #end

    #resources :tools, :only => :index, :controller => "interpret/tools", :as => "#{Interpret.scope}_tools" do
      #collection do
        #get :fetch
        #post :upload
        #post :migrate
      #end
    #end

    ##match "tools", :to => "interpret/tools#index", :as => "interpret_tools"
    #match "search", :to => "interpret/search#index", :as => "interpret_search"
    #match "search_for", :to => "interpret/search#perform", :as => "interpret_search_for"
  #end
end
