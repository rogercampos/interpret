Rails.application.routes.draw do
  scope Interpret.scope do
    #match "/", :to => "#{Interpret.controller}#index"

    resources :translations, :except => [:new, :create, :destroy, :show], :controller => Interpret.controller, :as => Interpret.resource_name do
      collection do
        get :fetch
        post :upload
        get :node
      end
    end
  end
end
