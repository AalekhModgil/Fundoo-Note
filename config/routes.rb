Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "users", to: "users#userRegistration"
      post "users/login", to: "users#userLogin"
      put "users/forget", to: "users#forgetPassword"
      put "users/reset/:id", to: "users#resetPassword"

      post "notes/create", to: "notes#createNote"
    end
  end
end