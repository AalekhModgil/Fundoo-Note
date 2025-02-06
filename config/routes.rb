Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "users", to: "users#userRegistration"
      post "users/login", to: "users#userLogin"
      put "users/forget", to: "users#forgetPassword"
      put "users/reset/:id", to: "users#resetPassword"

      post "notes/create", to: "notes#createNote"
      get "notes/getNote", to: "notes#getNote"
      get "notes/getNoteById/:id", to: "notes#getNoteById"
      put "notes/trashToggle/:id", to: "notes#trashToggle"
      put "notes/archiveToggle/:id", to: "notes#archiveToggle"
      put "notes/updateColour/:id/:colour", to: "notes#updateColour"
    end
  end
end