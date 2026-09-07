Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/token", to: "auth#create"
      post "sync/delta", to: "sync#delta"
      get "notes/query", to: "notes#query"
      get "notes", to: "notes#index"
      get "health", to: "health#show"
    end
  end
end
