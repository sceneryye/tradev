#encoding:utf-8
require 'digest/md5'
require 'rest-client'
require 'uri'


class Weihuo::WeixinPayController < ApplicationController

  Employee_share_ratio = 1
  Network_share_ratio = 0.2
  Company_share_ratio = 0.3
  Platform_share_ratio = 0.3


  def pay_with_goods
    good = Ecstore::Good.where(:bn => params[:id]).first
    product = good.products.first
    @img_url = good.medium_pic
    total_fee = (product.price * 100).to_i
    out_trade_no = product.product_id.to_s + Time.new.to_i.to_s + rand(10 ** 10).to_s.rjust(10, '0')
    order = Ecstore::Order.new do |o|
      o.order_id = out_trade_no
      o.total_amount = total_fee
      o.final_amount = total_fee
      o.pay_status = '0'
      o.ship_status = '0'
      o.createtime = Time.zone.now.to_i
      o.status = 'active'
    end


    supplier = Ecstore::Supplier.where(:name => '贸威').first
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    mch_id = supplier.mch_id
    attach = "shop_#{params[:shop_id]}"
    nonce_str = random_str 32
    body = product.name
    spbill_create_ip = '182.254.138.119'
    trade_type = 'NATIVE'
    notify_url = 'http://www.trade-v.com/weihuo/notify_page'
    post_data_hash = {:appid => weixin_appid, :mch_id => mch_id, :nonce_str => nonce_str, :body => body, :out_trade_no => out_trade_no, :total_fee => total_fee, :attach => attach, :spbill_create_ip => spbill_create_ip, :notify_url => notify_url, :trade_type => trade_type}
    sign = create_sign post_data_hash
    post_data_hash[:sign] = sign
    post_data_xml = to_label_xml post_data_hash

    post_url = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
    res_data_hash = Hash.from_xml(RestClient.post post_url, post_data_xml)
    if res_data_hash['xml']['return_code'] == 'SUCCESS' && res_data_hash['xml']['result_code'] == 'SUCCESS'
      @res_data_hash = res_data_hash['xml']['code_url']
      render :layout => 'standard'
    else
     return render :text => res_data_hash['xml']
   end
 end

 def notify_page


  return render :text => 'SUCCESS' if Ecstore::WeihuoShare.where(:remark => params["xml"]["out_trade_no"]).present?
  if params["xml"]["result_code"] == 'SUCCESS'

    order_params = {}
    order_params[:order_id] = params["xml"]["out_trade_no"][0..19]
    order_params[:total_amount] = params["xml"]["total_fee"].to_f / 100
    order_params[:final_amount] = params["xml"]["total_fee"].to_f / 100
    order_params[:pay_status] = '1'
    order_params[:createtime] = Time.zone.now.to_i
    order_params[:status] = 'active'
    order_params[:payment] = 'wxpay'
    order_params[:ship_status] = '0'
    order_params[:shop_id] = params["xml"]["attach"].split('_')[1]
    
    # client = Ecstore::Account.where(:login_name => params["xml"]["openid"])
    # if client.present?
      # order_params[:member_id] = client.first.account_id
    # else
      # order_params[:member_id] = Ecstore::WeihuoShop.where(:shop_id => order_params[:shop_id]).first.member_id
    # end
    order_params[:member_id] = Ecstore::Account.where('login_name like ?', "%#{params["xml"]["openid"]}%").first.account_id
    
    

    shop_id = order_params[:shop_id]


    supplier_id = Ecstore::Account.where('login_name like ?', "%#{params["xml"]["openid"]}%").try(:first).try(:supplier_id) || 78
    @order = Ecstore::Order.new order_params

    goods = Ecstore::Good.where(:goods_id => params[:xml][:out_trade_no][0..4].to_i).first
    profit = order_params[:final_amount] - goods.cost
    share_for_employee = profit * Employee_share_ratio
    share_for_network = profit * Network_share_ratio
    share_for_company = profit * Company_share_ratio
    share_for_platform = profit * Platform_share_ratio


    if supplier_id == nil
      supplier_id =78
    end
    
    product = goods.products.first

    @order.order_items << Ecstore::OrderItem.new do |order_item|
      order_item.product_id = product.product_id
      order_item.bn = product.bn
      order_item.name = product.name
      order_item.price = order_params[:total_amount]
      order_item.nums = 1
      order_item.item_type = "product"
      order_item.amount = order_params[:total_amount]
      order_item.goods_id = goods.goods_id
    end



    order_params.merge!(:ip=>request.remote_ip, :supplier_id=>supplier_id)



    if @order.save
      store = goods.store - 1
      product.update_attribute(:store, store)
      Ecstore::OrderLog.new do |order_log|
        order_log.rel_id = @order.order_id
        order_log.op_id = @order.member_id
        order_log.op_name = params["xml"]['openid']
        order_log.alttime = @order.createtime
        order_log.behavior = 'creates'
        order_log.result = "SUCCESS"
        order_log.log_text = "订单创建成功！"
      end.save

      if @order.shop_id>0 and @order.shop_id!=48
        auto_send = {}
        Ecstore::WeihuoShare.new do |weihuo|
          auto_send[:order_id] = weihuo.order_id = @order.order_id
          auto_send[:amount] = weihuo.amount = share_for_employee
          auto_send[:member_id] = weihuo.member_id = @order.weihuo_shop.user.member_id
          auto_send[:re_openid] = weihuo.open_id = @order.weihuo_shop.user.account.login_name.split('_')[0]
          auto_send[:wishing] = weihuo.wishing ='恭喜发财'
          auto_send[:act_name] = weihuo.act_name = '尾货良品'
          auto_send[:remark] = weihuo.remark = params["xml"]["out_trade_no"]
          weihuo.share_for_employee = share_for_employee
          weihuo.share_for_company = share_for_company
          weihuo.share_for_network = share_for_network
          weihuo.share_for_platform = share_for_platform
        end.save
      end


      supplier = Ecstore::Supplier.where(:id => supplier_id).first
      arr = ('0'..'9').to_a + ('a'..'z').to_a
      nonce_str = ''
      32.times do
        nonce_str += arr[rand(36)].upcase
      end

      re_openid = auto_send[:re_openid]
      re_openid = ['oVxC9uA1tLfpb7OafJauUm-RgzQ8', 'oVxC9uDhsiNDxWV4u7KdukRjceQM'][rand(2)] if params["xml"]["attach"].split('_')[1] == '99999'
      auto_send[:act_name] = '贸威官网随机红包' if params["xml"]["attach"].split('_')[1] =='99999'
      Rails.logger.info params["xml"]["attach"].split('_')[1]
      Rails.logger.info params["xml"]["attach"].split('_')[1] == '99999'
      Rails.logger.info re_openid

      total_amount = auto_send[:amount].present? ? (auto_send[:amount].to_f * 100).to_i : ''
      weixin_appid = supplier.weixin_appid
      weixin_appsecret = supplier.weixin_appsecret
      key = supplier.partner_key
      mch_id = supplier.mch_id
      mch_billno = mch_id + Time.zone.now.strftime('%F').split('-').join + rand(10000000000).to_s.rjust(10, '0')
      parameter = {
        :nonce_str => nonce_str, :mch_billno => mch_billno, :mch_id => mch_id, :wxappid => weixin_appid, :send_name =>'贸威',
        :re_openid => re_openid, :total_amount => total_amount, :total_num => 1, :wishing => auto_send[:wishing],
        :client_ip => '182.254.138.119', :act_name => auto_send[:act_name], :remark => auto_send[:remark]
      }
      stringA = parameter.select{|key, value|value.present?}.sort.map do |arr|
        arr.map(&:to_s).join('=')
      end
      stringA = stringA.join("&")
      @b = string_sing_temp = stringA + "&key=#{key}"
      sign = (Digest::MD5.hexdigest string_sing_temp).upcase
      parameter[:sign] = sign
      parameter
      params_str = ''
      parameter.each do |key, value|
       params_str += "<#{key}>" + "<![CDATA[#{value}]]>" + "</#{key}>"
     end
     @a = params_xml = '<xml>' + params_str + '</xml>'
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
     share = Ecstore::WeihuoShare.where(:order_id => auto_send[:order_id]).first

     if res_data_hash["xml"]["return_code"] == 'SUCCESS'
      share.update_attribute(:status, 1)
      share.update_attribute(:return_message, res_data_hash["xml"]["return_code"])
    else
      share.update_attribute(:return_message, res_data_hash)
    end

    return render :text => 'SUCCESS'
  end
end
end

def template_information
  if params[:openid].present?
    post_url = "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=#{access_token}"
    bn = params["content"]
    product = Ecstore::Good.where(:bn => bn).try :first
    return render :text => '该商品不存在！' unless product
    url = "http://www.trade-v.com/products/#{bn}"
    post_data_hash = {
      :touser => 'oVxC9uA1tLfpb7OafJauUm-RgzQ8',
      :template_id => 'CWfKatdhLf0Z0ip78RTSYyn8URPEOLv0umXnEmlHNGA',
      :url => url,
      :data => {:first => {:value =>'新品上线', :color => "#173177"},
      :orderProductPrice => {:value => "#{product.price}",
      :color => "#173177"},
      :orderProductName => {:value => "#{product.name}", :color => "#173177"}
    }
  }
  post_data_json = post_data_hash.to_json
  res_data_json = RestClient.post post_url, post_data_json
  res_data_hash = ActiveSupport::JSON.decode res_data_json
  if res_data_hash['errmsg'] == 'ok'
    render :text => "success"
  else
    render :text => "#{res_data_hash['errcode']}"
  end
end
end

def qrcode
  post_url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{access_token}"
  post_data_hash = {:action_name => 'QR_LIMIT_SCENE', :action_info => {:scene => {:scene_id => 111}}}
  post_data_json = post_data_hash.to_json
  res_data_hash = ActiveSupport::JSON.decode(RestClient.post post_url, post_data_json)
  encode_url = URI.escape(res_data_hash['ticket'])
  @get_url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{encode_url}"
  # @qrcode_img = RestClient.get get_url
  # @url = res_data_hash['url']
  # @a = @qrcode_img.Content_type
  render :layout => 'standard'
end

def test_qrcode
  render :layout => 'mobile'
end




private

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



end
