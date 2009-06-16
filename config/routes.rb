ActionController::Routing::Routes.draw do |map|
  map.resources :data_objects do |data_object|
    data_object.resources :data_entries
  end

  map.resources :data_types do |data_type|
    data_type.resources :data_fields
  end

  map.resources :data_types, :shallow => true do |data_type|
    data_type.resources :data_objects
  end

  map.resources :stats, :collection => {:destroy_all => :delete}, 
                        :member => {:location_more => :get}

  map.resources :food_items

  # route automatically added by taskr4rails plugin
  map.taskr4rails "taskr4rails", :controller => 'taskr4rails', :action => 'execute'

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller


  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "index"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.

  # Allow downloading Web Service WSDL as a file with an extension
  # instead of a file named 'wsdl'
  map.connect ':controller/service.wsdl', :action => 'wsdl'
  map.connect 'payform/interface/:action',
    :controller => "/payform/interface"
  # Install the default route as the lowest priority.
  map.connect 'support/:dept/:loc/plain', :controller => 'support', :action => 'index', :plain => true
  map.connect 'support/:dept/:loc'  , :controller => 'support', :action => 'index'

  map.connect ':controller/:action/:id'
end
