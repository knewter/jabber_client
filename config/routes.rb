ActionController::Routing::Routes.draw do |map|
  map.resources :messages
  map.resources :jabber_users

  map.resources :users,
    :member => { :suspend   => :put,
                 :unsuspend => :put,
                 :purge     => :delete }

  map.resource :session

  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil

  map.logout   '/logout',   :controller => 'sessions', :action => 'destroy'
  map.login    '/login',    :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users',    :action => 'create'
  map.signup   '/signup',   :controller => 'users',    :action => 'new'

  map.connect '', :controller => 'jabber_users'

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
