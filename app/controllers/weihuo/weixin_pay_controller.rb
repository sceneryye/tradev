require 'digest/md5'
require 'rest-client'

class Weihuo::WeixinPayController < ApplicationController
  # goods with courier
  def pay_with_goods
    product = Ecstore::Good.where(:bn => params[:id]).first.products.frist
    total_fee = product.price * 100
    out_trade_no = product.product_id.to_s + Time.newo.to_i.to_s + rand(10 ** 10).to_s.rjust(10, '0')
    order = Ecstore::Order.new do |o|
      o.order_id = out_trade_no
      o.total_amount = total_fee
      o.final_amount = total_fee
      o.pay_status = '0'
      o.ship_status = '0'
      o.create_time = Time.now.to_i
      o.status = 'active'
    end
    order.save
    # create post data
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    mch_id = supplier.mch_id
    nonce_str = random_str 32
    body = product.name
    spbill_create_ip = '182.254.138.119'
    trade_type = 'NATIVE'
    notify_url = '182.254.138.119'
    post_data_hash = {:appid => wexin_apppid, :mchid => mchid, :nonce_str => nonce_str, :body => body, :out_trade_no => out_trade_no, :total_fee => total_fee, :spbill_create_ip => spbill_create_ip, :notify_url => notify_url, :trade_type => trade_type}
    sign = create_sign post_data_hash
    post_data_hash[:sign] = sign
    post_data_xml = post_data_hash.to_xml
    # post data
    post_url = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
    res_data_hash = Hash.from_xml(RestClient.post post_url, post_data_xml)
    if res_data_hash['xml']['return_code'] == 'SUCCESS' && res_data_hash['xml']['result_code'] == 'SUCCESS'
      return render :text => res_data_hash['xml']['code_url']
    else
      return render :text => res_data_hash['xml']
    end
  end


  private
  
  def random_str str_length
    arr = ('0'..'9').to_a + ('a'..'z').to_a
    nonce_str = ''
    str_length.times do
      nonce_str += arr[rand(36)].upcase
    end
  end

  def create_sign hash
    key = 'nQHdhE6QiPLcfeguqKTdax2ExunyYJpG'
    stringA = hash.select{|key, value|value.present?}.sort.map do |arr|
      arr.map(&:to_s).join('=')
    end
    stringA = stringA.join("&")
    string_sing_temp = stringA + "&key=#{key}"
    sign = (Digest::MD5.hexdigest string_sing_temp).upcase
  end

end
