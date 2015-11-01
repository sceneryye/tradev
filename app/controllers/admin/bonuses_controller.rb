#encoding:utf-8
require 'digest/md5'
require 'rest-client'
require 'erb'
include ERB::Util

class Admin::BonusesController < Admin::BaseController
  def get_users
    supplier = Ecstore::Supplier.where(:name => '贸威').first
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    get_access_token = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{weixin_appid}&secret=#{weixin_appsecret}"
    access_token = ActiveSupport::JSON.decode(get_access_token)['access_token']
    get_users_list = RestClient.get "https://api.weixin.qq.com/cgi-bin/user/get?access_token=#{access_token}&next_openid="
    users_list = ActiveSupport::JSON.decode(get_users_list)['data']['openid']
    page = (params[:page].to_i - 1) || 0
    users_list_partial = arr_paginate(users_list).first[params[:page].to_i || 0]
    @pages_number = arr_paginate(users_list).last
    @users_information = []
    users_list_partial.each do |open_id|
      @users_information << ActiveSupport::JSON.decode(RestClient.get("https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{open_id}&lang=zh_CN"))
    end
            # return render :text => get_users_list

  end

  def send_bonus
    supplier = Ecstore::Supplier.where(:name => '贸威').first
    #Random string
    arr = ('0'..'9').to_a + ('a'..'z').to_a
    nonce_str = ''
    32.times do 
      nonce_str += arr[rand(36)].upcase
    end

    re_openid = params[:re_openid]
    total_amount = params[:total_amount].to_i
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    key = supplier.weixin_secret_key
    mch_id = supplier.mch_id
    mch_billno = mch_id + Time.now.strftime('%F').split('-').join

    parameter = {
      :nonce_str => nonce_str, :mch_billno => mch_billno, :mch_id => mch_id, :wxappid => weixin_appid, :send_name =>'贸威优品商城',
      :re_openid => re_openid, :total_amount => total_amount, :total_num => 1, :wishing => params[:wishing], 
      :client_ip => '182.254.138.119', :act_name => params[:act_name], :remark => params[:remark]
    }

    stringA = parameter.select{|key, value|value.present?}.sort.map do |arr|
      arr.map(&:to_s).join('=')
    end

    stringA = stringA.join("&")
    #return render :text => stringA
    string_sing_temp = stringA + "&key=#{key}"

    sign = (Digest::MD5.hexdigest string_sing_temp).upcase
    parameter[:sign] = sign
    #return render :text => string_sing_temp  + "sign=#{sign}"
    params_str = ''
    parameter.each do |key, value|
      params_str += "<#{key}>" + "<![CDATA[#{value}]]>" + "</#{key}>"
    end
    params_xml = '<xml>' + params_str + '</xml>'

    url = 'https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack'
    @a = res_data = RestClient.post url, params_xml, :content_type => :xml, :accept => :xml
    @res_data_hash = Hash.from_xml res_data
    render 'send_bonus'
  end

  private

  def arr_paginate arr
    page_numbers = 50
    pages_count = arr.length % page_numbers == 0 ? arr.length / page_numbers : arr.length / page_numbers + 1
    pages = []
    pages_count.times do |num|
      pages << arr.slice((page_numbers * num)...(page_numbers * (num + 1)))
    end
    return [pages, pages_count]
  end

end



