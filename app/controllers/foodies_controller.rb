#encoding:utf-8
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
    notify_url = 'http://182.254.137.73:5000/wechat_notify_url'
    post_data_hash = {:appid => weixin_appid, :mch_id => mch_id, :nonce_str => nonce_str, :body => body, :out_trade_no => out_trade_no, :total_fee => total_fee, :attach => attach, :openid => openid, :spbill_create_ip => spbill_create_ip, :notify_url => notify_url, :trade_type => trade_type}
    sign = create_sign post_data_hash
    post_data_hash[:sign] = sign
    post_data_xml = to_label_xml post_data_hash

    post_url = 'https://api.mch.weixin.qq.com/pay/unifiedorder'
    res_data_hash = Hash.from_xml(RestClient.post post_url, post_data_xml)
    # return render :text => res_data_hash
    if res_data_hash["xml"]["return_code"] == 'SUCCESS'
      @url = "http://182.254.137.73:5000/events/#{params[:event_id]}"
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