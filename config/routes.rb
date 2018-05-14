# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :v1 do
    resources :requests, controller: :packages, only: [:index, :show, :create], param: :bag_id
    post "/requests/:bag_id/complete", controller: :queue_items, action: :create

    resources :packages, only: [:index, :show], param: :bag_id
    get "/packages/:bag_id/events", controller: :events, action: :index

    resources :events, only: [:index]

    resources :bags, only: [:index, :show], controller: :packages, param: :bag_id
    get "/bags/:bag_id/events", controller: :events, action: :index

    # We foresee the need for destroy; currently out of scope.
    resources :queue_items, only: [:index, :show], path: :queue

    resources :audits, only: [:index, :create, :show]
  end
end
