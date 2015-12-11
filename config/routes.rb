#encoding:utf-8
require 'httpclient'
Modengke::Application.routes.draw do

post 'temp_info_api' => 'weihuo/weixin_pay#temp_info_api'
post 'foodie_notify_url' => 'foodies#foodie_notify_url'
post 'send_group_message_api' => 'weihuo/weixin_pay#send_group_message_api'
get 'foodies/foodie_pay' => 'foodies#foodie_pay'
  namespace :weihuo do
    get 'pay_with_goods' => 'weixin_pay#pay_with_goods'
    get 'qrcode' => 'weixin_pay#qrcode'
    get 'test_qrcode' => 'weixin_pay#test_qrcode'
    post 'notify_page' => 'weixin_pay#notify_page'
    post 'template_information' => 'weixin_pay#template_information'
    get 'shops/add' => 'shops#add'
    post 'shops/goods_added' => 'shops#goods_added'
    get 'goods_detail/:id' => 'shops#goods_detail'
    get 'shops/share' => 'shops#share'
    get 'shops/manage' => 'shops#manage'
    get 'shops/show_members' => 'shops#show_members'
    get 'shops/member_detail' => 'shops#member_detail'
    get 'shops/show_bonuses' => 'shops#show_bonuses'
    get 'shops/show_goods' => 'shops#show_goods'
    get 'shops/show_notice' => 'shops#show_notice'
    get 'shops/user_center' => 'shops#user_center'
    get 'shops/using_guide' => 'shops#using_guide'
    get 'shops/my_orders' => 'shops#my_orders'
    get 'shops/my_addresses' => 'shops#my_addresses'
    get 'shops/show_orders' => 'shops#show_orders'
    get 'shops/order_detail' => 'shops#order_detail'
    post 'shops/modify_ship_status' => 'shops#modify_ship_status'
    get 'shops/show_qrcode' => 'shops#show_qrcode'
    get 'shops/bonus_detail' => 'shops#bonus_detail'
    get 'shops/my_visited_shops' => 'shops#my_visited_shops'

    resources :orgnizations
    resources :orders

    resources :shops do
      collection do
        get :gallery
        get :admin
        get :admin_visitors
        get :admin_orders
        get :user_center
        get :categories
        get :orderlist
        get :brand
        get :mobile_search

      end

      member do
        get :shop
        get :category_goods
      end
    end
  end


  


  resources :mobile do
  	collection do
  		get :gallery
      get :admin
      get :admin_visitors
      get :admin_orders
      get :user_center
      get :categories
      get :orderlist
      get :brand
      get :mobile_search

  	end

    member do
      get :shop
      get :category_goods
    end
  end


  resources :distributions do

    collection do
      get :cart
      get :bookmark
      get :orderproducts
      get :ordernew
    end

    member do
      get 'add_to_cart'
      get :product
      get :add_to_bookmark
      get :category
    end
  end

  #scope :module => "shop" do
  get 'shop'=>'shop/shopinfos#myshop'
  namespace :shop do

    resource :shopinfos do
      member do
        get 'index'
        get 'show_goods'
        post 'add_goods'
        get 'adderror'
        get 'my_goods'
        get 'goods_details'
        get :myshop
        get :goods_destroy
        post 'goods_destroy'
        get 'myorder'
        get 'details_trade'
        post "fendian"
        delete 'delete_order'
      end
    end

   # get "/shopuser"=>"shopuser#index" ,:controller=>"shopusers"

    resource :shopusers do
      collection do
        get "index"
        get "clients"
        get "share"
        get "branch"
        get "user"
        post "edit"
        get "delete"
        post "submit_delete"
      end
    end

    resource :visitors do
      collection do
        get 'istrue'
        post 'my_add_shopping'
        get 'my_shopping_cart'
        get 'order_clearing'
        get 'order_show'
      end
    end
  end


  resources :commissions do
    collection do
      get  'platform'
      get 'bank_info'
    end

    member do
      get 'paid'
    end
  end

  ####万家物流
  resources :manco do
    #万家主页面
    get 'manco_comment'  ,:on=>:collection
    get   'index'  ,:on=>:collection
    get 'map' ,:on=>:collection
    get  'main' ,:on=>:collection    ###万家介绍
    get  'history' ,:on=>:collection  ####万家历史
    post 'blackboardfind_e',:on=>:collection  ###查询运价
    get  'user'   ,:on=>:collection
    #万家快递页面
    post 'mancoluodipei',:on=>:collection
    get 'find_manco',:on=>:collection
    get "black_index"  ,:on=>:collection   ##小黑版首页
    get "express"  ,:on=>:collection
    post "serach"  ,:on=>:collection
    get "blackbord",:on=>:collection
    post "blackbord_add" ,:on=>:collection
    get "follow",:on=>:collection    ###快递跟踪
    post "follow",:on=>:collection    ###快递跟踪
    get 'user',:on=>:collection
    get 'good_source', :on=>:collection  ###货源信息
    post 'blackgood_add',:on=>:collection
    get 'black_good_index' ,:on=>:collection
    get 'show_carblack',:on=>:collection
    get 'departure' ,:on=>:collection
    post 'departure_edit',:on=>:collection
    post 'edit_addr',:on=>:collection
    get 'departure_new',:on=>:collection
    post 'creat_addr',:on=>:collection
    get 'cart_goods',:on=>:collection
    get 'advance',:on=>:collection
    get 'choose_express',:on=>:collection
    get 'local_express',:on=>:collection
    post 'l_express',:on=>:collection
    get 'city',:on=>:collection
  end



  resources :tairyo do                   # #大渔饭店
    get   'index'  ,:on=>:collection
    get   'group'  ,:on=>:collection
    get   'tuangouxiang'  ,:on=>:collection
    get   'comment'  ,:on=>:collection
    get   'tese'  ,:on=>:collection
    get   'user'  ,:on=>:collection
    get   'map'  ,:on=>:collection
    get 'tairyo_comment' ,:on=>:collection
    get 'showorder' ,:on=>:collection
  end


  post 'users/tairyo' =>"users#tairyo_user" ,:controller=>"users"

  #    #优惠卷
  resources :coupons do
    get  'get',:on=>:member

    #        #评论+优惠卷
    get 'comment_t'=>"comments#tairyo_comment",:controller=>"comments"
    post 'comment'=>"comments#tairyo",:controller=>"comments"

    get 'mycoupon'=>"coupon#mycoupon",  :controller=>"coupons"
    #    #特色
  end

  mount WeixinRailsMiddleware::Engine, at: "/"


  root :to=>"home#index",:constraints=>{ :subdomain=>/^(www)?$/ }
  get 'blank'=>"home#blank"
  get 'home'=>"home#index"


  resources :pages, :only=>[:show]

  namespace :auth do
    resources :accounts

    resources :email139 do
      get 'callback',:on=>:member
    end

    resources :weixin do
      get 'callback',:on=>:member
      
    end
    resources :weibo do
      get 'callback',:on=>:collection
    end
    resources :douban do
      get 'callback',:on=>:collection
    end
  end

  resources :sessions
  resources :users do
    get 'forgot_password', :on=>:collection
    post 'send_reset_password_instruction', :on=>:collection
    get 'reset_password',:on=>:collection
    post 'search', :on=>:collection
    post 'change_password',:on=>:collection
  end

  resources :vshop do
    collection do
      get 'login'
      get 'register'
      get 'article'
      get 'apply'
      post 'search'
      post 'change_password'
      get 'goods'
      get 'orders'
      get 'members'
      get 'weixin'
      post "black_good_destory"
      post "destory"
      get "notice"
      get "clients"
      get "to_foodie"
    end
    member do
      get :user
      get :category
      get :commodity
      get :order
      # post :payments
      get :payments
      get :native
      post :paynotifyurl
      get :paynotifyurl
      get :feedback
    end
=begin
    resources :payments do
      collection do
        get 'callback'
        get 'debug'
      end

      member do
        get 'pay'
        match ':adapter/notify'=>"payments#notify", :as=>"notify"
        match ':adapter/callback'=>"payments#callback", :as=>"callback"
        if Rails.env == 'development'
          get 'test_notify'
          get 'test_callback'
        end
      end
    end
=end
  end

  get 'auto_login'=>"sessions#auto_login"
  get 'auto_login2'=>"sessions#auto_login2"
  get 'shop_login'=>"sessions#shop_login"
  get 'autologin1'=>"sessions#auto_login1"
  get 'login'=>"sessions#new"
  get 'mlogin'=>"sessions#new_mobile"
  get 'mregister'=>"sessions#register_mobile"
  post 'login'=>"sessions#create"
  post 'mlogin'=>"sessions#create"
  get 'logout'=>"sessions#destroy"
  get 'topmenu'=>"home#topmenu"

  scope :module=> "events" do
    resources :user_survey, :controller=>"survey" do
      post "add_mobile", :on=>:collection

    end


  end

  namespace :events do
    resources :applicants

    resources :foodie do
      collection do
        get 'index'
        post 'add_foodie'
        get 'user_foodie'
        get 'detail'
      end
    end

    resources :party do
      collection do
        get 'index'
        get 'list'
        post 'stepone'
        get 'steptwo'
        post 'steptwo'
        get 'list'
        get 'user_party'
        get 'detail'
      end
    end

  end

  resources :events


  scope :module => "blog" do
    #constraints :subdomain => "blog" do
    root :to => "articles#index"
    resources :articles

    #end
  end

  scope :module => "magazine" do
    # match 'subscription_success' => "topics#index"
    resources :topics do
      resources :pages
    end
    match '/more_topics' => 'topics#more'
    match '/list_topics' => 'topics#list'
    match '/flash' => 'flashes#index'
  end

  scope :module => "memberships" do
    match '/vip' => 'vip#index'
    resource  :card do
      collection do
        get 'search'

        get 'activation'
        post 'confirm_activation'
        post 'validate_activation'
        post 'activate'
        get 'complete_activation'
        post 'input_mobile'
        post 'select'
        put 'update_mobile'
        put 'modify_mobile'
        get 'cancel_mobile'

        get 'purchase'
        scope "purchase" do
          post 'confirm_buyer'
          post 'confirm_user'
          get 'user'
        end

        get 'send_sms_code'

      end
    end
    resources  :member_cards
  end

  get 'admin'=>'admin/sessions#new'

  namespace :admin do

    resources :weihuos do
      post "export", :on=>:collection
      post "import", :on=>:collection
      post "downorder", :on=>:collection
      put 'batch',:on=>:collection
      get "black_weihuo"   , :on=>:collection
      put "black_weihuo_edit" , :on=>:collection
      get "black_weihuo_new" , :on=>:collection
      post "black_weihuo_new" , :on=>:collection
      get 'select_all',:on=>:collection
      get 'search', :on=>:collection
      collection do 
        get :goods
        get :organisations
        get :employees
        get :shops
        get :clients
        get :shares  
        get :import
        get :downorder

      end
    end

    # subdomain = nil
    # subdomain = "www" if Rails.env == "production"
    # constraints :subdomain => subdomain do
    get 'logout'=>'sessions#destroy'
    get 'get_users' => 'bonuses#get_users'
    get 'find_user' => 'bonuses#find_user'
    post 'send_bonus' => 'bonuses#send_bonus'
    resources :tracks do
      get :pages,:on=>:collection
    end

    resources :carts do

    end

    resource :rules do
      collection do
        get 'index'
      end
    end

    resource :tuans do
      collection do
        get 'index'
        put 'edit'
      end
    end


    resources :shops do
      collection do
        get 'detail'
      end
    end

    resources :wechat do
      get :menu,:on=>:collection
      get :menu_edit,:on=>:collection
      get :followers, :on=>:collection
      get :followers_import, :on=>:collection
      get :follower_renew,:on=> :collection
      get :groups, :on=>:collection
      get :batch_sending, :on=>:collection
      get :weixin,:on=>:collection
    end
    resources :resources
    resources :permissions do

    end
    resources :suppliers do
      get 'update_state',:on=>:collection
      get 'reco', :on => :member
    end

    resources :sessions
    resources :coupons
    resources :express_rules

    resources :goods_cats do
      get :create_top,:on=>:collection
      get :toggle_future,:on=>:member
      get :toggle_agent,:on=>:member
      get :toggle_sell,:on=>:member
      post :save_top,:on=>:collection
    end
    resources :goods_types do
      put :updateType,:on=>:member
    end
    resources :goods_labels do
      put :updateLabel,:on=>:member
      get :createLabel,:on=>:collection
    end
    resources :brand_adms do
      get :delete
      put :update_brand,:on=>:member
    end
    resources :black_good do

    end

    resources :goods do
      get "black_good"   , :on=>:collection
      put "black_good_edit" , :on=>:collection
      get "black_good_new" , :on=>:collection
      post "black_good_new" , :on=>:collection
      get "tairyo_show",  :on=>:collection
      post "export", :on=>:collection
      post "import", :on=>:collection
      post "remove_spec_item",:on=>:member
      get "add_spec_item",:on=>:member
      get "spec",:on=>:member
      put "update_spec",:on=>:member
      get 'select_goods',:on=>:collection
      get 'collocation',:on=>:member
      get 'set_suits',:on=>:member
      get 'cancel_suits',:on=>:member
      post 'create_collocation',:on=>:collection
      get 'search', :on=>:collection
      get 'select_gifts',:on=>:collection
      put 'batch',:on=>:collection
      get 'select_all',:on=>:collection

      get :toggle_future,:on=>:member
      get :toggle_agent,:on=>:member
      get :toggle_sell,:on=>:member
    end
    resources :spec_items

    resources :images do
      post "mark", :on=>:collection
      post "rollback",:on=>:collection
      post "refresh",:on=>:collection
    end
    resources :articles do
      post 'set_position',:on=>:collection
    end
    resources :topics do
      post 'set_position',:on=>:collection
      post 'published_at',:on=>:member
    end
    resources :pages

    resources :members do
      post "export",:on=>:collection
      post "column_reload",:on=>:collection
      post "send_sms",:on=>:collection
      post "send_sms2",:on=>:collection
      get :info,:on=>:member
      put :updateInfo,:on=>:member
    end

    resources :cards do
      get 'buy',:on=>:member
      get 'use',:on=>:member
      get 'edit_user',:on=>:member
      get 'edit_pay',:on=>:member
      get 'logs', :on=>:member
      post 'import', :on=>:collection
      post "export",:on=>:collection
      get "tag",:on=>:collection
      put "untag",:on=>:member
      put "cancel_order",:on=>:member
    end

    resources :users do
      get 'search',:on=>:collection
      post 'newuser',:on=>:collection
      put 'send_sms_code',:on=>:member
      put 'buy_card',:on=>:member
      put 'use_card',:on=>:collection
      get 'select', :on=>:member
      put 'validate_mobile',:on=>:member
    end
    resources :member_cards

    resources :tag_exts

    resources :configs

    resources :labels

    resources :emails do
      get 'send_all',:on=>:collection
    end

    resources :categories

    resources :applicants

    resources :events do
      get 'applicants',:on=>:member
    end

    resources :homes

    resources :brand_pages do
      get 'toggle', :on=>:member
      put 'order', :on=>:member
      put 'reco', :on=>:member
    end

    resources :promotions

    resources :new_coupons do
      get 'download', :on=>:member
      get  'select_coupons', :on=>:collection
    end

    resources :user_coupons

    resources :orders do
      collection do
        get 'search'
        post :export
        put 'batch'
      end

      member do
        get 'detail'
        get 'pay'
        post 'dopay'
        get 'delivery'
        post 'dodelivery'
        get 'print_order'
        get 'print_preparer'
        get 'reship'
        post 'doreship'
        get 'refund'
        post 'dorefund'
        get :comment
        put :update_memo
      end
    end

    resources :static_pages
    resources :footers

    resources :metas

    resources :specifications

    resources :tags

    resources :offline_coupons do
      get 'downloads',:on=>:member
    end

    resources :virtual_goods do
      post 'import', :on=>:collection
    end

    resources :payment_logs

    # end
  end
 
  scope :module => "store" do

    get 'search' => "search#index", :as=> :search
    get  'prime_beef'  =>"goods#prime_beef", :as=>"goods" ,:controller=>"goods"
    get 'food_beverage'  =>"goods#food_beverage", :as=>"goods" ,:controller=>"goods"
    get 'quality_products' =>"goods#quality_products", :as=>"goods" ,:controller=>"goods"
    get 'world_food' =>"goods#world_food", :as=>"goods" ,:controller=>"goods"
    get 'fashion' =>"goods#fashion", :as=>"goods" ,:controller=>"goods"
    get 'black_tea'=>"goods#black_tea", :as=>"goods" ,:controller=>"goods"
    get 'mproducts' =>"goods#mproduct", :as=>"goods" ,:controller=>"goods"
    post '/goods/manco_cart'=>"goods#manco_cart",  :controller=>"goods"
    get 'show_goodblack' =>  "goods#show_goodblack",  :as=>"goods" ,:controller=>"goods"   ###货源信息
    get 'mancoproduct' =>"goods#mancoproduct",  :as=>"goods" ,:controller=>"goods"
    get 'tairyoall'=>"goods#tairyoall",  :as=>"goods" ,:controller=>"goods"         ###金芭浪直接订单
    get 'tproducts' =>"goods#tairyo_tuan", :as=>"goods" ,:controller=>"goods"
    post'manco/serach_goods_manco'=>"goods#serach_goods_manco",:controller=>"goods"

    post 'goods/manco_express'=>"goods#manco_express",:controller=>"goods"    #通过AJAX查询出来价钱
    resources :products, :as=>"goods", :controller=>"goods" do
      # get 'newin',:on=>:collection
      get 'newest',:on=>:collection
      put 'fav',:on=>:member
      put 'unfav',:on=>:member
      get 'price',:on=>:member
      get 'more',:on=>:collection
      get 'suits', :on=>:collection
      get 'more_suits', :on=>:collection

    end

    resources :suppliers


    resources :tuan do
      collection do
       get 'index'
        get 'wares_details'



      end
    end

    resources :coupons, :controller=>"offline_coupons" do
      post 'download',:on=>:member
    end

    resources :vgoods, :controller=>"virtual_goods",:only=>[:index,:show]
    post 'cart/tairyo_add'=>"cart#tairyo_add",:as=>:add_to_cart   #团购商品添加购物车
    post 'cart/add'=>"cart#add",:as=>:add_to_cart
    post 'cart/manco_add'=>"cart#manco_add" ,:as=>:add_to_cart
    post 'cart/tairyoall_add'=>"cart#tairyoall_add" ,:as=>:add_to_cart

    resources :order_attachments

    resources :cart do
      get 'manco_express'  ,:on=>:collection
      get 'distribution_manco',:on=>:collection
      post 'add',:on=>:collection
      get 'show_tairyo',:on=>:collection   ###直接下单购物车
      get 'mobile', :on=>:collection
      get 'tairyo_cart',:on=>:collection   ##小头像上的查看订单
      post 'tairyo', :on=>:collection      #大渔订餐 不是团购
      get 'jinbalang',:on=>:collection
      get 'manco_black_buy',:on=>:collection
      get 'add', :on=>:collection
    end

    resources :brands,:only=>[:index,:show]
    resources :users
    resources :vshop
    resources :country, :as=>"countries", :controller=>"countries"
    resources :gallery, :as=>"cats", :controller=>"cats"
    resources :galleries

    get 'vgroup'=>"cats#show_group",:as=>"cats",:controller=>"cats"  #金芭浪饭店团购
    get 'mgallery' =>"cats#show_mobile", :as=>"cats",:controller=>"cats"
    get 'mgoods_list'=>"cats#goods_list" ,:as=>"cats", :controller=>"cats"
    resources :goods,  :as=>"orders", :controller=>"orders" do
      member do
        get :goods
      end
    end

    get 'share' =>"orders#share"
    get 'shop_share'=>"orders#shop_share"

    resources :orders, :except=>[:index] do
      member do
        get 'to_inventory'
        get 'out_inventory'
        post :pay
        get :detail
        get :goods

      end

      collection do
        get 'goodblack'       ###货源小黑板
        post 'destroyaddr'
        get 'check_coupon'
        get  'new_mobile'
        get  'new_tairyo'
        get 'new_manco'
        post 'new_manco'
        get 'new_mobile_addr'
        get 'new_manco_addr'
        get 'departure'
        post 'arrival'
        get 'arrival'
        get 'mancoder_show'   ###显示万家当前用户的所有订单
        get 'tairyo_order'
        get 'mobile_show_order'
        get 'wuliu_show_order'
        get 'index_mobile'
        get 'share_order'   ###推荐订单
        get 'mobile_show'
        get 'wuliu_show'    ###万家订单页面
        get 'addr_detail'
        get 'new_mobile_addr'
        post 'edit_addr'
        get 'edit_manco_addr'
        post 'xiugai_addr'
        post 'manco_detail'
        get 'manco_card'
        get 'advance'   ##预付款信息

      end
    end

    resources :payments do

      collection do
        get 'callback'
        get 'debug'
      end

      member do
        get 'pay'
        match ':adapter/notify'=>"payments#notify", :as=>"notify"
        match ':adapter/callback'=>"payments#callback", :as=>"callback"
        if Rails.env == 'development'
          get 'test_notify'
          get 'test_callback'
        end
      end
    end
  end

  scope '(:agent)',:module => "store" do
    resources :products, :as=>"goods", :controller=>"goods" do
      get 'newin',:on=>:collection
      get 'newest',:on=>:collection
      put 'fav',:on=>:member
      put 'unfav',:on=>:member
      get 'price',:on=>:member
    end

    # post 'cart/add'=>"cart#add",:as=>:add_to_cart
    resources :cart do
      post 'add',:on=>:collection
    end

    resources :cats do
      get 'list_spec',:on=>:collection
    end

    resources :users

    resources :gallery, :as=>"cats", :controller=>"cats"

    resources :galleries
  end


  scope :module => "patch" do
    resource :profile do
      member do
        get 'password'
        put 'modify_password'
        get 'mancouser'
        put 'mancouser_add'
      end
    end
    resources :cards do
      member do
        get 'loss'
        get 'contact'
        get 'cancel_loss'
        # get 'send_sms_code'
        post 'confirm_lost'
        post 'confirm_cancel'
        get 'buyer_tel'
        get 'user_tel'
        post 'update_buyer_tel'
        post 'update_user_tel'
        get 'activation'
      end
    end
    resource :member do
      member do
        get 'orders'
        get 'coupons'
        get 'cards'
        get 'advance'
        get 'after_sale'
        get 'favorites'
        get 'goods'
        get 'inventorys'
        get 'inventorylog'
        post 'export_inventory'
      end
    end

    resources :member_addrs do
      get "mobile"  ,:on=>:collection
      get 'new_memberaddr_add' ,:on=>:collection
      get '_form_manco_second' ,:on=>:collection
      post 'addship' ,:on=>:collection
    end
    resources :aftersales do
      get 'instruction', :on=>:collection
    end

    resource :validation do
      get 'email'
      get 'mobile'
      post 'verify'
      post 'sent'
      get 'verify_email'
    end
  end

  resources :comments,:only=>[:create]

  mount Ckeditor::Engine => '/ckeditor'

  scope ":agent" do
    resources :home
    resources :cart do
      get 'add', :on=>:collection
    end
    resources :cats
    resources :sessions  do
      get 'login', :on=>:collection
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
