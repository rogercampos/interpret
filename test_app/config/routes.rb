InterpretApp::Application.routes.draw do
  root :to => redirect("/es")

  mount Interpret::Engine => "/interpret"

  scope ":locale" do
    get "archives", :to => "pages#archives"
    get "links", :to => "pages#links"
    get "resources", :to => "pages#resources"
    get "contact", :to => "pages#contact"

    post "toggle_edition_mode", :to => "application#toggle_edition_mode"

    namespace :admin do
      get 'dashboard', :to => "dashboard#index"
    end

    root :to => "pages#index"
  end
end
