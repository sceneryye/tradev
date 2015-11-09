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
  return render :text => 'SUCCESS'
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
