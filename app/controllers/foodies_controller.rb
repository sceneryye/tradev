#encoding:utf-8
require 'rest-client'
require 'digest/sha1'
class FoodiesController < ApplicationController

  def foodie_pay
    supplier = Ecstore::Supplier.find(78)
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    mch_id = supplier.mch_id
    attach = "#{params[:event_id]}_#{params[:participant_id]}_#{params[:user_id]}"
    nonce_str = random_str 32
    out_trade_no = Time.new.to_i.to_s + rand(10 ** 10).to_s.rjust(10, '0')
    body = params[:event_name]
    openid = params[:openid]
    spbill_create_ip = '182.254.138.119'
    trade_type = 'JSAPI'
    total_fee = (params[:money].to_f * 100).to_i
    notify_url = 'http://vshop.trade-v.com/foodie_notify_url'
    post_data_hash = {:appid => weixin_appid, :mch_id => mch_id, :nonce_str => nonce_str, :body => body, :out_trade_no => out_trade_no, :total_fee => total_fee, :attach => attach, :openid => openid, :spbill_create_ip => spbill_create_ip, :notify_url => notify_url, :trade_type => trade_type}
    sign = create_sign post_data_hash
    post_data_hash[:sign] = sign
    post_data_xml = to_label_xml post_data_hash

    post_url = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
    res_data_hash = Hash.from_xml(RestClient.post post_url, post_data_xml)
    # return render :text => res_data_hash
    if res_data_hash["xml"]["return_code"] == 'SUCCESS'
      @url = "http://vshop.trade-v.com/foodiegroup/#{params[:type_name]}/#{params[:event_id]}"
      prepay_id = res_data_hash["xml"]["prepay_id"]
      @timestamp = Time.now.to_i
      @nonce_str = random_str 32
      @package = "prepay_id=#{prepay_id}"
      @appId = weixin_appid
      data = {:appId => weixin_appid, :timeStamp => @timestamp, :nonceStr => @nonce_str, :package => @package, :signType => 'MD5'}
      @paySign = create_sign data
      render :layout => false
    else
      render :text => res_data_hash
    end
  end

  def foodie_notify_url
    url = "http://vshop.trade-v.com/foodiegroup/wechat_notify_url"
    RestClient.post url, params["xml"]
    return render :text => 'success'
  end

  def foodie_group_share

    @title = "#{params["name"]}推荐您加入#{params["groupname"]}"
    @img_url = params["imgurl"]
    @desc = params[:desc].blank? ? '吃货帮，让我们一起去团购天下健康美食' : params[:desc]
    @groupid = params[:groupid]
    supplier = Ecstore::Supplier.where(:id => 78).first
    @timestamp = Time.now.to_i
    @appId = supplier.weixin_appid
    @noncestr = random_str 16
    @jsapilist = ['onMenuShareTimeline', 'onMenuShareAppMessage', 'onMenuShareQQ', 'onMenuShareWeibo', 'onMenuShareQZone']
    @jsapi_ticket = get_jsapi_ticket
    post_params = {
      :noncestr => @noncestr,
      :jsapi_ticket => @jsapi_ticket,
      :timestamp => @timestamp,
      :url => request.url.gsub("trade", "vshop.trade-v.com")
    }
    @sign = create_sign_for_js post_params
    @a = [post_params, request.url.gsub("trade", "vshop.trade-v.com")]
    render :layout => false
  end

  def go_to_foodie_from_share
    if params[:openid].present?
      @nickname = Ecstore::Account.where(:login_name => params[:openid]).first.user.weixin_nickname
      @headimgurl = Ecstore::Account.where(:login_name => params[:openid]).first.user.weixin_headimgurl
      @groupid = params[:groupid]
    end
    render :layout => false
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
      nonce_str += arr[rand(36)]
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

 def create_sign_for_js hash
  key = Ecstore::Supplier.where(:name => '贸威').first.partner_key
  stringA = hash.select { |key, value| value.present? }.sort.map do |arr|
    arr.map(&:to_s).join('=')
  end
  stringA = stringA.join("&")
  sign = (Digest::SHA1.hexdigest stringA)
end



def get_jsapi_ticket
  if current_account.present?
    supplier = Ecstore::Supplier.where(:id => 78).first
    return supplier.jsapi_ticket if supplier.expires_at.to_i > Time.now.to_i && supplier.jsapi_ticket.present?
    access_token = get_jsapi_access_token
    get_url = 'https://api.weixin.qq.com/cgi-bin/ticket/getticket'
    res_data_json = RestClient.get get_url, {:params => {:access_token => access_token, :type => 'jsapi'}}
    res_data_hash = ActiveSupport::JSON.decode res_data_json
    if res_data_hash['errmsg'] == 'ok'
      jsapi_ticket = res_data_hash['ticket']
      supplier.update_attributes(:jsapi_ticket => jsapi_ticket)
    end
    jsapi_ticket
  end
end

def get_jsapi_access_token
  supplier = Ecstore::Supplier.where(:id => 78).first
  return supplier.access_token if supplier.expires_at.to_i > Time.now.to_i
  get_url = 'https://api.weixin.qq.com/cgi-bin/token'
  res_data_json = RestClient.get get_url, {:params => {:appid => supplier.weixin_appid, :grant_type => 'client_credential', :secret => supplier.weixin_appsecret}}
  res_data_hash = ActiveSupport::JSON.decode res_data_json
  access_token = res_data_hash["access_token"]
  expires_at = Time.now.to_i + res_data_hash['expires_in'].to_i
  supplier.update_attributes(:access_token => access_token, :expires_at => expires_at)
  access_token
end



end