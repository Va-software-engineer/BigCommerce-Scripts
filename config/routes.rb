Rails.application.routes.draw do
  root to: 'welcome#home'
  get '/auth/:name/callback', to: 'omniauths#callback'
  get '/load', to: 'omniauths#load'
  get '/uninstall', to: 'omniauths#uninstall'

  # API Routes
  namespace :api do
    get '/store_script_details', to: 'script_tags#store_script_details'
    post '/update_script', to: 'script_tags#update_script_data'
    post '/update_store_property', to: 'script_tags#update_store_property'
  end
end
