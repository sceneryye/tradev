#encoding:utf-8
require 'rest-client'


class Weihuo::ShopsController < ApplicationController

  
  layout 'weihuo'




  def index
    @shop_ids = []
    login_name = current_account.login_name.split('_shop_').first
    names = Ecstore::Account.where("login_name like ?", "%#{login_name}%").each do |user| 
     shop_id = user.login_name.split('_shop_').last 
     @shop_ids << shop_id if shop_id.to_i > 0 && shop_id != '49' 
   end
   @shop_exist = false
   @shop_ids.each do |shop_id|

    @shop_exist = true if Ecstore::WeihuoShop.find_by_shop_id(shop_id).try(:openid) == current_account.login_name.split('_shop_').first
  end
  Rails.logger.info "shop_ids => #{@shop_ids}"
end

def user_center
  user = Ecstore::Account.where('login_name like ?', "%#{current_account.login_name.split('_shop_')[0]}%")
  account_ids = user.map(&:account_id)
  @order_ids = []
  account_ids.each do |account_id|
    Ecstore::Order.where(:member_id => account_id).each do |order|

      @order_ids << order.order_id
    end
  end

  @shop_ids = []
  user.each do |account|
    @shop_ids << account.login_name.split('_shop_')[1]
  end
  @shop_ids = @shop_ids.select{|shop_id|Ecstore::WeihuoShop.where(:shop_id => shop_id).present?}
  @line_items = Ecstore::Cart.where(:member_id => current_account.account_id).first
  
end

def using_guide
end

def my_orders
  user = Ecstore::Account.where("login_name like ?", "%#{current_account.login_name.split('_shop_')[0]}%")
  account_ids = user.map(&:account_id)
  @order_ids = []
  account_ids.each do |account_id|
    Ecstore::Order.where(:member_id => account_id).order('createtime desc').each do |order|

      @order_ids << order.order_id
    end
  end
end

def my_visited_shops
  openid = current_account.login_name.split('_shop_')[0]
  @shop_ids = []
  Ecstore::Account.where("login_name like ?", "%#{openid}%").each do |account|
    @shop_ids << account.login_name.split('_shop_')[1]
  end
  @shop_ids = @shop_ids.select{|shop_id|Ecstore::WeihuoShop.where(:shop_id => shop_id).present?}
end

def my_addresses
  openid = current_account.login_name.split('_shop_')[0]
  @member_ids = []
  @member_address_ids = []
  Ecstore::Account.where("login_name like ?", "%#{openid}%").each do |account|
    @member_ids << account.account_id if account.user.present?
  end
  @member_ids.each do |member_id|
    Ecstore::MemberAddr.where(:member_id => member_id).order("addr_id desc").each do |member_addr|
      @member_address_ids << member_addr.addr_id if member_addr.present? && member_addr.area.present? && member_addr.addr.present? && member_addr.name.present?
    end
  end
end



def manage
  @members = Ecstore::Account.all.select{|member|member.shop_id == params[:shop_id].to_i}
  @bonuses = Ecstore::WeihuoShare.where(:open_id => current_account.login_name.split('_shop_')[0])
  @goods = Ecstore::Good.where(:supplier_id => 10)
  @orders = Ecstore::Order.where(:shop_id => params[:shop_id])

end

def show_members
  @members = Ecstore::Account.order(:account_id).select{|member|member.shop_id == params[:shop_id].to_i}
end

def member_detail
  @member = Ecstore::Member.find_by_member_id(params[:member_id])
  @orders = Ecstore::Order.where(:member_id => params[:member_id], :shop_id => params[:shop_id], :pay_status => '1')
  @total_amount = @orders.present? ? @orders.inject(0){|sum, order|sum + order.total_amount} : 0
  @largest_money = @orders.present? ? @orders.select{|order|order.total_amount.present?}.sort{|a,b|b.total_amount <=> a.total_amount}.first.total_amount : 0
  @time = @orders.present? ? Time.at(@orders.sort{|a, b|b.createtime <=> a.createtime}.first.createtime).strftime('%F %T') : '暂无'
end

def show_bonuses
  @bonuses = Ecstore::WeihuoShare.where(:open_id => current_account.login_name.split('_shop_')[0]).paginate(:page => params[:page], :per_page => 20).order('id DESC')
end

def show_goods
  @goods = Ecstore::Good.where(:supplier_id => 10).paginate(:page => params[:page], :per_page => 20).order('name ASC')
end

def show_orders

  @orders = Ecstore::Order.where(:shop_id => params[:shop_id]).paginate(:page => params[:page], :per_page => 20).order('createtime DESC')
end

def show_qrcode
end

def order_detail
  @order = Ecstore::Order.where(:order_id => params[:order_id]).first
  @user = Ecstore::Member.where(:member_id => @order.member_id).first
  product_id = Ecstore::OrderItem.where(:order_id => params[:order_id]).first.product_id
  @product = Ecstore::Product.where(:product_id => product_id).first
end

def bonus_detail
  @bonus = Ecstore::WeihuoShare.where(:order_id => params[:order_id]).first
  @order = Ecstore::Order.where(:order_id => params[:order_id]).first
  @user = Ecstore::User.find_by_member_id(@order.member_id)
  if @bonus.return_message.present? && @bonus.return_message.split(":").length > 2
    @message = @bonus.return_message.split(":")[3].split(" ")[0]
  end
end

def modify_ship_status
  if params[:ship_status] == '1'
    order = Ecstore::Order.where(:order_id => params[:order_id]).first
    order.update_attribute(:ship_status, '1')
    if Ecstore::WeihuoShare.where(:order_id => params[:order_id]).first.payment_method == 'scan_qrcode'
      order.update_attribute(:status, 'finish')

      order_id = params[:order_id]
      if Ecstore::WeihuoShare.where(:order_id => order_id).present? && Ecstore::WeihuoShare.where(:order_id => order_id).first.status == 0

        supplier = Ecstore::Supplier.find_by_id(78)
        weixin_appid = supplier.weixin_appid
        weixin_appsecret = supplier.weixin_appsecret
        key = supplier.partner_key
        mch_id = supplier.mch_id
        mch_billno = mch_id + Time.zone.now.strftime('%F').split('-').join + rand(10000000000).to_s.rjust(10, '0')
        arr = ('0'..'9').to_a + ('a'..'z').to_a
        nonce_str = ''
        32.times do
          nonce_str += arr[rand(36)].upcase
        end
        data = {}
        
        
        shop_id = order.shop_id
        data[:re_openid] = shop_id == 49 ? ['oVxC9uA1tLfpb7OafJauUm-RgzQ8', 'oVxC9uDhsiNDxWV4u7KdukRjceQM'][rand(2)] : Ecstore::WeihuoShop.where(:shop_id => shop_id).first.openid
        data[:wishing] = '加油加油加油！！！'
        data[:act_name] = shop_id == 49 ? '贸威官网随机红包' : '尾货良品'
        data[:total_amount] = (Ecstore::WeihuoShare.where(:order_id => order_id).first.amount * 100).to_i
        data[:nonce_str] = nonce_str
        data[:mch_billno] = mch_billno
        data[:mch_id] = mch_id
        data[:wxappid] = weixin_appid
        data[:send_name] = '尾货良品老板'
        data[:total_num] = 1
        data[:client_ip] = '182.254.138.119'
        data[:remark] = order.mark_text
        stringA = data.select{|key, value|value.present?}.sort.map do |arr|
          arr.map(&:to_s).join('=')
        end
        stringA = stringA.join("&")
        string_sing_temp = stringA + "&key=#{key}"
        sign = (Digest::MD5.hexdigest string_sing_temp).upcase
        data[:sign] = sign

        params_str = ''
        data.each do |key, value|
          params_str += "<#{key}>" + "<![CDATA[#{value}]]>" + "</#{key}>"
        end
        params_xml = '<xml>' + params_str + '</xml>'
        uri = URI.parse('https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack')

        cert = File.read("#{ Rails.root }/lib/maowei_cert/apiclient_cert.pem")

        key = File.read("#{ Rails.root }/lib/maowei_cert/apiclient_key.pem")

        http = Net::HTTP.new(uri.host, uri.port)

        http.use_ssl = true if uri.scheme == 'https'

        http.cert = OpenSSL::X509::Certificate.new(cert)

        http.key = OpenSSL::PKey::RSA.new(key, '商户编号')

        http.ca_file = File.join("#{ Rails.root }/lib/maowei_cert/rootca.pem")

        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        res_data = ''

        http.start { http.request_post(uri.path, params_xml) { |res| res_data = res.body } }
        res_data_hash = Hash.from_xml res_data
        share = Ecstore::WeihuoShare.where(:order_id => order_id).first

        if res_data_hash["xml"]["return_code"] == 'SUCCESS'
          share.update_attribute(:status, 1)
          share.update_attribute(:return_message, res_data_hash["xml"]["return_code"])
        else
          share.update_attribute(:return_message, res_data_hash)
        end
      end
    end
    return render :text => 'success'
  end
end

def show_notice
end

def show
  shop_id = params[:shop_id] || params[:id]
  bns = ["a0100017", "a0100018", "a0100019"]
  @pics = bns.map do |bn|
    Ecstore::Good.where(:bn => bn).first.medium_pic
  end  
  if params[:from] == 'chooseshop'
    return redirect_to "/shop_login?id=78&shop_id=#{shop_id}&return_url=/weihuo/shops/#{shop_id}&platform=mobile"
  end
  if !current_account.present? || current_account.supplier_id != 78

    return redirect_to "/shop_login?id=78&shop_id=#{shop_id}&return_url=/weihuo/shops/#{shop_id}&platform=mobile"
  end
  openid= current_account.login_name.split('_shop_')[0]
  shop = Ecstore::WeihuoShop.where(:openid => openid)
  if shop.present? && params[:id] != shop.first.shop_id.to_s
    return redirect_to "/weihuo/shops/#{shop.first.shop_id}"
  end
  return redirect_to '/weihuo/shops' if params[:enterin] == 'first'
    # return render :text => shop_id == '49'
    # if current_account.present?
      # open_id = current_account.login_name.split('_shop_')[0]
      # if shop_id == '49' && Ecstore::WeihuoShop.where(:openid => open_id).present?
        # sign_out
        # return redirect_to "/weihuo/shops/#{Ecstore::WeihuoShop.where(:openid => open_id).first.shop_id}"
      # end
    # end
    @shop = Ecstore::WeihuoShop.find(params[:shop_id] || params[:id])
    @goods = Ecstore::Good.where(:supplier_id => 10).paginate(:per_page => 30, :page => params[:page]).order(:name)
    
  end

  # 申请店铺
  def new
    if current_account.blank?
      return redirect_to "/auto_login2?return_url=#{URI.escape 'http://www.trade-v.com/weihuo/shops/new'}&platform=mobile&from=new"
    end

    @exiting_shop = Ecstore::WeihuoShop.where(:openid => current_account.login_name.split('_shop_')[0])
    

    
    @organisations = Ecstore::WeihuoOrganisation.all
    organisation = Ecstore::WeihuoOrganisation.where(:name => params[:organisation_name])
    @employees = Ecstore::WeihuoEmployee.where(:weihuo_organisation_id => organisation.first.id) if organisation.present?
    @shop = Ecstore::WeihuoShop.new
  end

  def create
    member_id = params[:member_id]
    open_id = Ecstore::Account.where(:account_id => member_id).first.login_name.split('_shop_')[0]
    return render :text => '该店铺已经存在！' if Ecstore::WeihuoShop.where(:openid => open_id).present?
    shop_params = {}
    shop_params[:member_id] = params[:member_id]

    openid = Ecstore::Account.where(:account_id => params[:member_id]).first.login_name.split("_shop_")[0]
    shop_params[:weihuo_organisation_id] = Ecstore::WeihuoOrganisation.where(:name => params[:organisation_name]).first.id
    shop_params[:employee_name] = params[:employee_name]
    shop_params[:employee_mobile] = params[:employee_mobile]

    shop_params[:status] = '1'
    get_url = "https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{open_id}&lang=zh_CN"
    user_info = RestClient.get get_url
    shop_params[:logo] = ActiveSupport::JSON.decode(user_info)['headimgurl']
    shop_params[:openid] = open_id

    @shop = Ecstore::WeihuoShop.new(shop_params)
    if @shop.save!
      account = Ecstore::Account.where(:account_id => params[:member_id]).first

      account.update_column(:shop_id, @shop.shop_id)
      Ecstore::WeihuoEmployee.where(:name => params[:employee_name]).first.update_attributes(:area => params[:province] + params[:city], :address => params[:address], :shop_id => @shop.shop_id)

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
    openid = current_account.login_name.split('_shop_')[0]
    @shop = Ecstore::WeihuoShop.where(:openid => openid).first
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
    @shop = Ecstore::WeihuoShop.where(:shop_id => params[:shop_id]).first

  end

  helper_method :pay_with_goods, :total_profit, :goods_profit, :username_for_avatar
  private

  def pay_with_goods bn
    goods = Ecstore::Good.where(:bn => bn).first

    @img_url = goods.medium_pic
    total_fee = (goods.price * 100).to_i
    out_trade_no = goods.goods_id.to_s + Time.new.to_i.to_s + rand(10 ** 10).to_s.rjust(10, '0')
    supplier = Ecstore::Supplier.where(:name => '贸威').first
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    mch_id = supplier.mch_id
    attach = "shop_#{params[:shop_id]}"
    nonce_str = random_str 32
    body = goods.name
    spbill_create_ip = '182.254.138.119'
    trade_type = 'NATIVE'
    notify_url = 'http://www.trade-v.com/weihuo/notify_page'
    post_data_hash = {:appid => weixin_appid, :mch_id => mch_id, :nonce_str => nonce_str, :body => body, :out_trade_no => out_trade_no, :total_fee => total_fee, :spbill_create_ip => spbill_create_ip, :notify_url => notify_url, :trade_type => trade_type, :attach => attach}
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
  nonce_str
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

def total_profit weihuoshare
  weihuoshare.inject(0){|sum, item| sum + item.try(:amount)}
end

def goods_profit goods
  organisation_id = Ecstore::WeihuoShop.where(:shop_id => params[:shop_id]).first.weihuo_organisation_id
  share = Ecstore::WeihuoOrganisation.find(organisation_id).share
  (goods.price - goods.cost) * share
end

def choose_layout
  shop_id = params[:shop_id] || params[:id]
  Ecstore::WeihuoShop.where(:shop_id => shop_id).first.layout
end


# def username_for_avatar
  # Pinyin.t(self.username)
# end


end