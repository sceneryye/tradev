#encoding:utf-8
require 'digest/md5'
require 'rest-client'
require 'uri'


class Weihuo::WeixinPayController < ApplicationController

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
      o.createtime = Time.now.to_i
      o.status = 'active'
    end


    supplier = Ecstore::Supplier.where(:name => '贸威').first
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    mch_id = supplier.mch_id
    nonce_str = random_str 32
    body = product.name
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
      render :layout => 'standard'
    else
     return render :text => res_data_hash['xml']
   end
 end

 def notify_page
  if params["xml"]["result_code"] == 'SUCCESS'

    order_params = {}
    order_params[:order_id] = params["xml"]["out_trade_no"][0..19]
    order_params[:total_amount] = params["xml"]["total_fee"].to_f / 100
    order_params[:final_amount] = params["xml"]["total_fee"].to_f / 100
    order_params[:pay_status] = '1'
    order_params[:createtime] = Time.now.to_i
    order_params[:status] = 'active'
    order_params[:member_id] = Ecstore::Account.where(:login_name => params["xml"]["openid"]).first.user.member_id
    order_params[:shop_id] = Ecstore::Account.where(:login_name => params["xml"]["openid"]).first.shop_id
    # url = "http://www.trade-v.com/orders"
    # RestClient.post url, order_params

    shop_id = order_params[:shop_id]


    supplier_id = Ecstore::Account.where(:login_name => params["xml"]["openid"]).first.supplier_id
    @order = Ecstore::Order.new order_params

    if supplier_id == nil
      supplier_id =78
    end
    goods = Ecstore::Good.where(:goods_id => order_params[:order_id][0..4]).first
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
        share_for_weihuo_shop = (@order.order_items.select{ |order_item| order_item.item_type == 'product' }
          .collect{ |order_item|order_item.product.price-order_item.product.cost}.inject(:+).to_f)*@order.weihuo_shop.weihuo_organisation.share

        Ecstore::WeihuoShare.new do |weihuo|
          weihuo.order_id = @order.order_id
          weihuo.amount = share_for_weihuo_shop
          weihuo.member_id = @order.weihuo_shop.user.member_id
          weihuo.open_id = @order.weihuo_shop.user.account.login_name.split('_')[0]
          weihuo.wishing ='恭喜发财'
          weihuo.act_name = '尾货良品'
          weihuo.remark = "订单#{@order.order_id}"
        end.save
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
