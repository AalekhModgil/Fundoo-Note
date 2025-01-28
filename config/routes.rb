# Rails.application.routes.draw do
#   namespace :api do
#     namespace :v1 do
#       resources :users, only: [:create,  :show , :index ,:destroy]

#       post "up" => "user#up",as: :Api_v1_up
#     end
#   end

#   get "up" => "rails/health#show", as: :rails_health_check

# end

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "users", to: "users#userRegistration"

      get "users", to: "users#showAllUsers"

      get "users/:id", to: "users#showUserById"

      delete "users/:id", to: "users#deleteUserById"

    end
  end
end