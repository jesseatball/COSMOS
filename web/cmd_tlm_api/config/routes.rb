# encoding: ascii-8bit

# Copyright 2021 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# This program may also be used under the terms of a commercial or
# enterprise edition license of COSMOS if purchased from the
# copyright holder

Rails.application.routes.draw do
  resources :routers, only: [:index, :create]
  get '/routers/:id', to: 'routers#show', id: /[^\/]+/
  match '/routers/:id', to: 'routers#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/routers/:id', to: 'routers#destroy', id: /[^\/]+/

  resources :interfaces, only: [:index, :create]
  get '/interfaces/:id', to: 'interfaces#show', id: /[^\/]+/
  match '/interfaces/:id', to: 'interfaces#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/interfaces/:id', to: 'interfaces#destroy', id: /[^\/]+/

  resources :targets, only: [:index, :create]
  get '/targets/:id', to: 'targets#show', id: /[^\/]+/
  match '/targets/:id', to: 'targets#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/targets/:id', to: 'targets#destroy', id: /[^\/]+/

  resources :gems, only: [:index, :create]
  get '/gems/:id', to: 'gems#show', id: /[^\/]+/
  match '/gems/:id', to: 'gems#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/gems/:id', to: 'gems#destroy', id: /[^\/]+/

  resources :microservices, only: [:index, :create]
  get '/microservices/:id', to: 'microservices#show', id: /[^\/]+/
  match '/microservices/:id', to: 'microservices#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/microservices/:id', to: 'microservices#destroy', id: /[^\/]+/

  get '/microservice_status/:id', to: 'microservice_status#show', id: /[^\/]+/

  post '/tools/position/:id', to: 'tools#position', id: /[^\/]+/
  resources :tools, only: [:index, :create]
  get '/tools/:id', to: 'tools#show', id: /[^\/]+/
  match '/tools/:id', to: 'tools#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/tools/:id', to: 'tools#destroy', id: /[^\/]+/

  resources :scopes, only: [:index, :create]
  get '/scopes/:id', to: 'scopes#show', id: /[^\/]+/
  match '/scopes/:id', to: 'scopes#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/scopes/:id', to: 'scopes#destroy', id: /[^\/]+/

  post '/plugins/install/:id', to: 'plugins#install', id: /[^\/]+/
  resources :plugins, only: [:index, :create]
  get '/plugins/:id', to: 'plugins#show', id: /[^\/]+/
  match '/plugins/:id', to: 'plugins#update', id: /[^\/]+/, via: [:patch, :put]
  delete '/plugins/:id', to: 'plugins#destroy', id: /[^\/]+/

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post "/api" => "api#api"
  get "/screen/:target" => "api#screens"
  get "/screen/:target/:screen" => "api#screen"
end
