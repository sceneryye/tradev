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
    order_params[:supplier_id] = 78
    order_params[:createtime] = Time.zone.now.to_i
    order_params[:status] = 'active'
    order_params[:payment] = 'wxpay'
    order_params[:ship_status] = '0'
    employee = Ecstore::WeihuoEmployee.where(:shop_id => params["xml"]["attach"].split('_')[1]).first
    order_params[:ship_area] = employee.area
    order_params[:ship_addr] = employee.address
    order_params[:ship_name] = employee.name
    order_params[:ship_mobile] = employee.mobile
    order_params[:mark_text] = params["xml"]["out_trade_no"]
    order_params[:shop_id] = params["xml"]["attach"].split('_')[1]
    order_params[:member_id] = Ecstore::Account.where('login_name like ?', "%#{params["xml"]["openid"]}%").first.account_id
    shop_id = order_params[:shop_id]
    supplier_id = Ecstore::Account.where('login_name like ?', "%#{params["xml"]["openid"]}%").try(:first).try(:supplier_id) || 78
    goods = Ecstore::Good.where(:goods_id => params[:xml][:out_trade_no][0..4].to_i).first
    profit = order_params[:final_amount] - goods.cost
    order_params[:share_for_employee] = share_for_employee = profit * Employee_share_ratio
    order_params[:share_for_network] = share_for_network = profit * Network_share_ratio
    order_params[:share_for_company] = share_for_company = profit * Company_share_ratio
    order_params[:share_for_platform] = share_for_platform = profit * Platform_share_ratio
    @order = Ecstore::Order.new order_params


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


    payments = @order.payments.new do |payment|
      payment.currency = 'CNY'
      payment.pay_app_id = 'wxpay'
      payment.payment_id = Ecstore::Payment.generate_payment_id
      payment.status = 'succ'
      payment.pay_ver = '1.0'
      payment.paycost = 0
      payment.account = 'TRADE-V | 跨境贸易 一键直达'
      payment.money = order_params[:final_amount]

      payment.member_id = payment.op_id = order_params[:member_id]
      payment.pay_account = Ecstore::Account.find_by_account_id(order_params[:member_id]).login_name
      payment.ip = request.remote_ip
      payment.t_begin = payment.t_confirm = Time.zone.now.to_i
      payment.pay_bill = Ecstore::Bill.new do |bill|
        bill.rel_id  = order_params[:order_id]
        bill.bill_type = "payments"
        bill.pay_object  = "order"
        bill.money = order_params[:final_amount]
      end
    end
    payments.save!

    if @order.save
      store = product.store - 1
      goods.update_attribute(:store, store)
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
          auto_send[:re_openid] = weihuo.open_id = @order.weihuo_shop.user.account.login_name.split('_shop_')[0]
          auto_send[:wishing] = weihuo.wishing ='加油加油加油！！！'
          auto_send[:act_name] = weihuo.act_name = '尾货良品'
          auto_send[:remark] = weihuo.remark = params["xml"]["out_trade_no"]
          weihuo.payment_method = 'scan_qrcode'
          weihuo.share_for_employee = share_for_employee
          weihuo.share_for_company = share_for_company
          weihuo.share_for_network = share_for_network
          weihuo.share_for_platform = share_for_platform
        end.save
      end
    end
    return render :text => 'SUCCESS'
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
      :touser => params[:openid],
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

#  该api接受hash格式的参数，方法为post， 需要openids， template_id， 以及模板对应的数据参数，url为可选参数。
def temp_info_api
  post_url = "https://api.weixin.qq.com/cgi-bin/message/template/send?access_token=#{access_token}"
  params.delete(:controller)
  params.delete(:action)
  params_hash = params
  openids = params_hash["openid"]
  template_id = params_hash["template_id"]
  url = params_hash["url"]
  opendis.each do |openid|
    post_data_hash = {
      :touser => openid,
      :template_id => template_id,
      :url => url,
      :data => params_hash["data"]
    }
    post_data_json = post_data_hash.to_json
    res_data_json = RestClient.post post_url, post_data_json
    res_data_hash = ActiveSupport::JSON.decode res_data_json
  end
  if res_data_hash['errmsg'] == 'ok'
    render :text => "success"
  else
    render :text => "#{res_data_json}"
  end
end

def send_group_message_api
  Rails.logger.info params
  # params_hash = ActiveSupport::JSON.decode params
  params.delete("controller")
  params.delete("action")
  params_hash = params
  Rails.logger.info params_hash.to_json
  Rails.logger.info params_hash["openids"]
  group_post_url = "https://api.weixin.qq.com/cgi-bin/message/mass/send?access_token=#{access_token}"
  #预览接口
  group_post_url = "https://api.weixin.qq.com/cgi-bin/message/mass/preview?access_token=#{access_token}"
  if params_hash["data"]["msgtype"] == "mpnews"
    if params_hash["img_url"].present?
      img_post_url = "https://api.weixin.qq.com/cgi-bin/media/uploadimg?access_token=#{access_token}"
      res_data = `curl -F media="#{params_hash["img_url"]}" "#{img_post_url}"`
      res_data_hash = ActiveSupport::JSON.decode res_data
      if res_data_hash["url"]
        pic_url = res_data_hash["url"]
        pic_text_post_url = "https://api.weixin.qq.com/cgi-bin/media/uploadnews?access_token=#{access_token}"
        res_data, res_data_hash = '', ''
        params_hash["data"]["thumb_media_id"] = pic_url
        params_json = params_hash.to_json
        res_data_json = RestClient.post pic_text_post_url, params_json
        res_data_hash = ActiveSupport::JSON.decode res_data_json
        media_id = res_data_hash["media_id"]
        mpnews_hash = {
          :touser => params_hash["openids"],
          :mpnews => {:media_id => media_id},
          :msgtype => "mpnews"
        }
        mpnews_json = mpnews_hash.to_json
        res_data_hash, res_data_json = '', ''
        res_data_json = RestClient.post group_post_url, mpnews_json
        res_data_hash = ActiveSupport::JSON.decode res_data_json
        return render :text => res_data_json
      end
    else
      return render :text => '缺少图片url，发送失败。'
    end
  elsif params_hash["data"]["msgtype"] == 'text'
    text_hash = {
      :touser => params_hash["openids"],
      :msgtype => "text",
      :text => {:content => params_hash["content"]}
    }
    text_json = text_hash.to_json
    res_data_json = RestClient.post group_post_url, text_json
    return render :text => res_data_json
  end
end

def qrcode
  post_url = "https://api.weixin.qq.com/cgi-bin/qrcode/create?access_token=#{access_token}"
  post_data_hash = {:action_name => 'QR_LIMIT_SCENE', :action_info => {:scene => {:scene_id => 111}}}
  post_data_json = post_data_hash.to_json
  res_data_hash = ActiveSupport::JSON.decode(RestClient.post post_url, post_data_json)
  encode_url = URI.escape(res_data_hash['ticket'])
  @get_url = "https://mp.weixin.qq.com/cgi-bin/showqrcode?ticket=#{encode_url}"

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

def access_token
  supplier = Ecstore::Supplier.where(:name => '贸威').first
  weixin_appid = supplier.weixin_appid
  weixin_appsecret = supplier.weixin_appsecret
  get_access_token = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{weixin_appid}&secret=#{weixin_appsecret}"
  access_token = ActiveSupport::JSON.decode(get_access_token)['access_token']
end



end
