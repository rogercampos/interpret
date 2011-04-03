InterpretApp::Application.routes.draw do
  scope "(:locale)" do
    get "archives", :to => "pages#archives"
    get "links", :to => "pages#links"
    get "resources", :to => "pages#resources"
    get "contact", :to => "pages#contact"

    post "toggle_edition_mode", :to => "application#toggle_edition_mode"
    root :to => "pages#index"
  end
end
