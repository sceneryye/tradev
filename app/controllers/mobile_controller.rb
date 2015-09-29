#encoding:utf-8

class MobileController < ApplicationController
  #before_filter :find_user
  layout 'mobile'

  def admin

    if @user
      if @user.member_id == 4403
        return redirect_to "/mobile/admin_orders"
      end
    end

    render :layout =>'mobile_admin'

  end

  def admin_orders

    if @user
      if @user.member_id==4403

        @orders_nw =Ecstore::Order.where(:shop_id=> 48).order("order_id desc")

        if params[:status].nil?
          @orders_nw = @orders_nw
        elsif
         @orders_nw = @orders_nw.where(:status=>params[:status])
       end

       if !params[:pay_status].nil?
        @orders_nw = @orders_nw.where(:pay_status=>params[:pay_status])
      end

      if !params[:ship_status].nil?
        @orders_nw = @orders_nw.where(:ship_status=>params[:ship_status])
      end

      @order_ids = @orders_nw.pluck(:order_id)


      @orders = @orders_nw.includes(:user).paginate(:page=>params[:page],:per_page=>30)

      return render :layout =>'mobile_admin'
    end

  end

  redirect_to '/mobile/admin'
end

def admin_visitors

  if @user
    if @user.member_id==4403

      shop_id = 48

      @total_vistors = Ecstore::ShopClient.where(:shop_id=>shop_id).count()

      @visitors=Ecstore::ShopClient.where(:shop_id=>shop_id).paginate(:page => params[:page], :per_page => 20).order("created_at desc")

      return render :layout =>'mobile_admin'
    end

  end

  redirect_to '/mobile/admin'
end

def user_center

end

def index

  @title = "贸威优品商城移动版"

  @galleries = Ecstore::TagExt.order("id desc").limit(10)

  @goods=Ecstore::Good.where(:marketable=>"true").order("goods_id DESC").limit(24)
  @brands = []
  Ecstore::Brand.all.each do |brand|
    @brands << brand if brand.goods.count > 2
    return if @brands.length > 3
  end

    #@home = Ecstore::Home.last
    #if signed_in?
    #  redirect_to params[:return_url] if params[:return_url].present?
    #end
  end

  def categories
   @cats = Ecstore::Category.where(:parent_id=>0)
 end

 def category_goods
   @cat = Ecstore::Category.find_by_cat_id(params[:id])
   case params[:gtype]
   when "2"
    @all_goods = @cat.all_goods(:future=>"true")
  when "3"
    @all_goods = @cat.all_goods(:agent=>"true")
  else
    @all_goods = @cat.all_goods(:sell=>"true")
  end
  order = params[:order]

  if order.present?
    col, sorter = order.split("-")
  else
    col, sorter =  %w{goods_id desc}
  end

  page  =  (params[:page] || 1).to_i
  per_page = 18

  if params[:brand].to_i > 0
    @all_goods.select! {|g| g.brand_id == params[:brand].to_i }
  end

  if params[:color].to_i > 0
    @all_goods.select! { |g| g.color_specs('id').include? params[:color].to_i }
  end


  if col&&sorter == 'asc'
    @goods = @all_goods.sort{ |x,y| x.attributes[col] <=> y.attributes[col] }.paginate(page,per_page)
  elsif col&&sorter == 'desc'
    @goods = @all_goods.sort{ |x,y| y.attributes[col] <=> x.attributes[col] }.paginate(page,per_page)
  else
             # @goods = @all_goods.sort{ |x,y| y.uptime <=> x.uptime }.paginate(page,per_page)
             @goods = @all_goods.paginate(page,per_page)
           end

         end

         def orderlist
          @supplier_id = params[:supplier_id]
          if  @user
            if @supplier_id == nil
              @supplier_id=78
            end

            @orders =  @user.orders.order("createtime desc")

      # if params["platform"]=="mobile"
      #   render :layout=>@supplier.layout
      # end
    else
      return_url={:return_url => "/mobile"}.to_query
      redirect_to "/auto_login?#{return_url}&id=#{supplier_id}"
    end
  end

  def show
    @no_need_login = 1

    @goods = Ecstore::Good.find(params[:id])

    @title = "贸威移动版"
    tag_name = params[:tag]
    @tag = Ecstore::TagName.find_by_tag_name(tag_name)

    @cat = @goods.cat

    @recommend_goods = []
    if @cat.goods.size >= 4
      @recommend_goods =  @cat.goods.where("goods_id <> ?", @goods.goods_id).order("goods_id desc").limit(4)
    else
      @recommend_goods += @cat.goods.where("goods_id <> ?", @goods.goods_id).limit(4).to_a
      @recommend_goods += @cat.parent_cat.all_goods.select{|good| good.goods_id != @goods.goods_id }[0,4-@recommend_goods.size] if @cat.parent_cat && @recommend_goods.size < 4
      @recommend_goods.compact!
      if @cat.parent_cat.parent_cat && @recommend_goods.size < 4
        count = @recommend_goods.size
        @recommend_goods += @cat.parent_cat.parent_cat.all_goods.select{|good| good.goods_id != @goods.goods_id }[0,4-count]
      end
    end

  end

  def shop
  	if @user
     @shop_goods = Ecstore::ShopsGood.where(:shop_id=>48)
     @galleries = Ecstore::TagExt.order("id desc").limit(6)
   else
    sid = params[:sid]

    if sid.blank?
     return render :text=>"No Sid"
   end

   redirect_to "/auth/email139?sid=#{sid}"

  	  #  redirect_uri="http%3a%2f%2fvshop.trade-v.com%2fauth%2femail139%2f#{sid}%2fcallback"
  	  #  @oauth2_url = "http://121.15.167.240:19090/SSOInterface/GetUserByKey"

  	#	return_url = "http://vshop.trade-v.com/mobile/shop?sid=#{sid}"
  	 #   return_url  = params[:return_url]
  	 #   session[:return_url] =  return_url
  	  #  redirect_to  @oauth2_url
  	end
  end

  def gallery
    tag_id = params[:id]
    @gallery = Ecstore::TagExt.where(:tag_id=>tag_id).first
    if @gallery.nil?
      return render :text=>"敬请期待"
    end
    @categories = Ecstore::Category.where("cat_id in (#{@gallery.categories})").order("p_order")

		#render :layout=> 'msite'

	end

  def blank
    @return_url = params[:return_url]
    render :layout=>nil
  end

  def topmenu
    render :layout=>nil
  end

  def mobile_search
    page  =  (params[:page] || 1).to_i
    per_page = 20

    @q = q = params[:q].strip
    q = q.gsub(/[\s,\.\*\+\/\-:'"!\&\^\[\]\(\)， 。：”’（）%@！、]+/,"%")
    @splits = q.split(/%+/)

    order = params[:order]
    if order.present?
      col, sorter = order.split("-")
      order = order.split("-").join(" ")
    else
      order = "uptime desc"
    end

    @goods = Ecstore::Good.selling.order(order)

    @splits.each do |key|
      @goods = @goods.joins(:brand).where("name like :key or brand_name like :key",:key=>"%#{key}%")
    end

    @goods = @goods.includes(:brand).paginate(:per_page=>per_page,:page=>page)

    
  end

end
