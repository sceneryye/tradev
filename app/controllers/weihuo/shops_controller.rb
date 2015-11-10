#encoding:utf-8
require 'rest-client'

class Weihuo::ShopsController < ApplicationController


 layout "weihuo1"



  # 所有店铺展示
  def index


  end

  def show

    @shop = Ecstore::WeihuoShop.find(params[:id])
    @goods_ids =[]
    Ecstore::WeihuoShopsGood.where(:shop_id => params[:id]).all.each do |w|
      @goods_ids << w.goods_id
    end
    
  end

  # 申请店铺
  def new
    @organisations = Ecstore::WeihuoOrganisation.all
    organisation = Ecstore::WeihuoOrganisation.where(:name => params[:organisation_name])
    @employees = Ecstore::WeihuoEmployee.where(:weihuo_organisation_id => organisation.first.id) if organisation.present?
    @shop = Ecstore::WeihuoShop.new
  end

  def create
    return render :text => '该店铺已经存在！' if Ecstore::Account.where(:account_id => params[:member_id]).first.shop_id.present?
    shop_params = {}
    shop_params[:member_id] = params[:member_id]
    openid = Ecstore::Account.where(:account_id => params[:member_id]).first.login_name
    shop_params[:organisation_id] = Ecstore::WeihuoOrganisation.where(:name => params[:organisation_name]).first.id
    shop_params[:employee_name] = params[:employee_name]
    shop_params[:employee_mobile] = params[:employee_mobile]
    shop_params[:name] = params[:shop_name]
    shop_params[:status] = '1'
    get_url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{openid}&lang=zh_CN"
    user_info = RestClient.get get_url
    shop_params[:logo] = ActiveSupport::JSON.decode(user_info)['headimgurl']
    
    @shop = Ecstore::WeihuoShop.new(shop_params)
    if @shop.save!
      account = Ecstore::Account.where(:account_id => params[:member_id]).first
      
      account.update_column(:shop_id, @shop.shop_id)

      redirect_to weihuo_shop_path(@shop)
    else
      render 'new'
    end

  end

  def goods_detail
    @goods = Ecstore::Good.find(params[:id])
    render :layout => 'mobile'
  end

  def edit
  end

  def add
    @goods = Ecstore::Good.where(:supplier_id => 10)
    member_id = current_account.account_id
    @shop = Ecstore::WeihuoShop.where(:member_id => member_id).first
  end

  def goods_added
    shop_id = params[:shop_id]
    goods_ids = params[:goods_ids].split(',')
    goods_ids.each do |goods_id|
      next if Ecstore::WeihuoShopsGood.where(:shop_id => shop_id, :goods_id => goods_id).present?
      shop_goods = Ecstore::WeihuoShopsGood.new(:shop_id => shop_id, :goods_id => goods_id)
      shop_goods.save!
    end
    redirect_to "/weihuo/shops/#{params[:shop_id]}"
  end

  def update
  end

  def share
    @url = "http://www.trade-v.com/weihuo/shops/#{params[:shop_id]}"
    render :layout => 'mobile'
  end

  helper_method :pay_with_goods
  private

  def pay_with_goods bn
    goods = Ecstore::Good.where(:bn => bn).first
    
    @img_url = goods.medium_pic
    total_fee = (goods.price * 100).to_i
    out_trade_no = goods.goods_id.to_s + Time.new.to_i.to_s + rand(10 ** 10).to_s.rjust(10, '0')
    order = Ecstore::Order.new do |o|
      o.order_id = out_trade_no
      o.total_amount = total_fee
      o.final_amount = total_fee
      o.pay_status = '0'
      o.ship_status = '0'
      o.createtime = Time.now.to_i
      o.status = 'active'
    end
    

    supplier = Ecstore::Supplier.where(:name => '贸威').first
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    mch_id = supplier.mch_id
    nonce_str = random_str 32
    body = goods.name
    spbill_create_ip = '182.254.138.119'
    trade_type = 'NATIVE'
    notify_url = 'http://www.trade-v.com/weihuo/notify_page'
    post_data_hash = {:appid => weixin_appid, :mch_id => mch_id, :nonce_str => nonce_str, :body => body, :out_trade_no => out_trade_no, :total_fee => total_fee, :spbill_create_ip => spbill_create_ip, :notify_url => notify_url, :trade_type => trade_type}
    sign = create_sign post_data_hash
    post_data_hash[:sign] = sign
    post_data_xml = to_label_xml post_data_hash

    post_url = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
    res_data_hash = Hash.from_xml(RestClient.post post_url, post_data_xml)
    if res_data_hash['xml']['return_code'] == 'SUCCESS' && res_data_hash['xml']['result_code'] == 'SUCCESS'
      @res_data_hash = res_data_hash['xml']['code_url']
      return @res_data_hash
    else
     return render :text => res_data_hash['xml']
   end
 end

 def to_label_xml hash
  params_str = ''
  hash.each do |key, value|
    params_str += "<#{key}>" + "<![CDATA[#{value}]]>" + "</#{key}>"
  end
  params_xml = '<xml>' + params_str + '</xml>'
end

def random_str str_length
  arr = ('0'..'9').to_a + ('a'..'z').to_a
  nonce_str = ''
  str_length.times do
    nonce_str += arr[rand(36)].upcase
  end
end

def create_sign hash
  key = Ecstore::Supplier.where(:name => '贸威').first.partner_key
  stringA = hash.select{|key, value|value.present?}.sort.map do |arr|
   arr.map(&:to_s).join('=')
 end
 stringA = stringA.join("&")
 string_sing_temp = stringA + "&key=#{key}"
 sign = (Digest::MD5.hexdigest string_sing_temp).upcase
end

def access_token
  supplier = Ecstore::Supplier.where(:name => '贸威').first
  weixin_appid = supplier.weixin_appid
  weixin_appsecret = supplier.weixin_appsecret
  get_access_token = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{weixin_appid}&secret=#{weixin_appsecret}"
  access_token = ActiveSupport::JSON.decode(get_access_token)['access_token']
end


end