Rails.application.routes.draw do
  root to: redirect("/sy/employees")

  namespace :sy do
    resources :employees, only: :index
  end

  namespace :api do
    namespace :v1 do
      resources :employees, only: :index
    end
  end
end
