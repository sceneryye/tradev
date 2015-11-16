#encoding:utf-8
class Store::GalleriesController < ApplicationController
  layout 'standard'

  skip_before_filter :authorize_user!,:only=>[:price]
  before_filter :find_user, :except=>[:price]
  skip_before_filter :find_path_seo, :find_cart!, :only=>[:newest]
  before_filter :find_tags, :only=>[:cheuksgroup,:newest]

  def show
    @no_need_login = 1
    
    if params[:supplier_id]
      supplier_id  = params[:supplier_id]
    end
    if supplier_id.nil?
      supplier_id =78
    end

    @gallery_id = (126..134).to_a
    @galleries = []
    @gallery_id.each do |id|
      @galleries << Ecstore::TagExt.where(:tag_id=>id).first
    end

    tag_id = params[:id] || 129
    @gallery = Ecstore::TagExt.where(:tag_id=>tag_id).first
    if @gallery.nil?
      return render :text=>"敬请期待"
    end
    condation = params[:cat_id].present? ? ({:cat_id => params[:cat_id]}) : ({:cat_id=>@gallery.categories.split(',')})
    @categories = Ecstore::Category.where(condation).order("p_order")
    
      @goods = Ecstore::Good.where(condation).order("p_order ASC , goods_id DESC").paginate(:per_page => 21, :page => (params[:page] || 1).to_i)
 

    @supplier = Ecstore::Supplier.find(supplier_id)

    @recommend_user = session[:recommend_user]

    if @recommend_user==nil &&  params[:wechatuser]
      @recommend_user = params[:wechatuser]
    end
    if @recommend_user
      member_id =-1
      if signed_in?
        member_id = @user.member_id
      end
      now  = Time.zone.now.to_i
      Ecstore::RecommendLog.new do |rl|
        rl.wechat_id = @recommend_user
        #  rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end
  end


  def index
  	@promotions= Ecstore::Promotion.where(:mallname=>"fashion").order("priority asc")

    @supplier = Ecstore::Supplier.find(params[:supplier_id])

    @recommend_user = session[:recommend_user]

    if @recommend_user==nil &&  params[:wechatuser]
      @recommend_user = params[:wechatuser]
    end
    if @recommend_user
      member_id =-1
      if signed_in?
        member_id = @user.member_id
      end
      now  = Time.zone.now.to_i
      Ecstore::RecommendLog.new do |rl|
        rl.wechat_id = @recommend_user
        #  rl.goods_id = @good.goods_id
        rl.member_id = member_id
        rl.terminal_info = request.env['HTTP_USER_AGENT']
        #   rl.remote_ip = request.remote_ip
        rl.access_time = now
      end.save
      session[:recommend_user]=@recommend_user
      session[:recommend_time] =now
    end

    render :layout=>@supplier.layout

  end


end