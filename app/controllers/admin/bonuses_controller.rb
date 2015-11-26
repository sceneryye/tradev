#encoding:utf-8
require 'digest/md5'
require 'rest-client'
require 'erb'
include ERB::Util

class Admin::BonusesController < Admin::BaseController
  before_filter :authorize_admin!
  def get_users

    supplier = Ecstore::Supplier.where(:name => '贸威').first
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    get_access_token = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{weixin_appid}&secret=#{weixin_appsecret}"
    access_token = ActiveSupport::JSON.decode(get_access_token)['access_token']
    get_users_list = RestClient.get "https://api.weixin.qq.com/cgi-bin/user/get?access_token=#{access_token}&next_openid="
    users_list = ActiveSupport::JSON.decode(get_users_list)
    users_list_count = users_list['count']
    users_list_openid = users_list['data']['openid']
    users_list_openid_partial = arr_paginate(users_list_openid).first[params[:page].to_i - 1 || 0]
    users_list_openid_partial_hash = users_list_openid_partial.map{|u| {"openid" => u, "lang" => "zh-CN"}}
    users_list_information = ActiveSupport::JSON.decode(RestClient.post("https://api.weixin.qq.com/cgi-bin/user/info/batchget?access_token=#{access_token}", {:user_list => users_list_openid_partial_hash}.to_json))
    @users_information = users_list_information['user_info_list']
    @pages_number = arr_paginate(users_list_openid).last
  end

  def find_user
    name = URI.unescape params[:name]
    if name.present?
      unionids = []
      Ecstore::Member.where("weixin_nickname like ?", "%#{name}%").each do |user|
        unionids << user.weixin_unionid
      end
      @unionids = unionids.uniq!
    end
  end

  def send_bonus
    if params[:order_id].present?
      share = Ecstore::WeihuoShare.where(:order_id => params[:order_id]).first
      if share.status != 0
        return render :text => {:status => share.status}.to_json
      end
    end
    supplier = Ecstore::Supplier.where(:name => '贸威').first

    arr = ('0'..'9').to_a + ('a'..'z').to_a
    nonce_str = ''
    32.times do
      nonce_str += arr[rand(36)].upcase
    end

    re_openid = params[:re_openid]
    total_amount = params[:total_amount].present? ? params[:total_amount].to_i * 100 : ''
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    key = Ecstore::Supplier.where(:name => '贸威').first.partner_key
    mch_id = supplier.mch_id
    mch_billno = mch_id + Time.zone.now.strftime('%F').split('-').join + rand(10000000000).to_s.rjust(10, '0')

    parameter = {
      :nonce_str => nonce_str, :mch_billno => mch_billno, :mch_id => mch_id, :wxappid => weixin_appid, :send_name =>'尾货良品老板',
      :re_openid => re_openid, :total_amount => total_amount, :total_num => 1, :wishing => params[:wishing],
      :client_ip => '182.254.138.119', :act_name => params[:act_name], :remark => params[:remark]
    }

    stringA = parameter.select{|key, value|value.present?}.sort.map do |arr|
      arr.map(&:to_s).join('=')
    end

    stringA = stringA.join("&")
    #return render :text => stringA
    @b = string_sing_temp = stringA + "&key=#{key}"

    sign = (Digest::MD5.hexdigest string_sing_temp).upcase
    parameter[:sign] = sign
    parameter


    params_str = ''
    parameter.each do |key, value|
     params_str += "<#{key}>" + "<![CDATA[#{value}]]>" + "</#{key}>"
   end
   @a = params_xml = '<xml>' + params_str + '</xml>'

    #url = 'https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack'

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
    @res_data_hash = Hash.from_xml res_data
    if params[:from] == 'weihuo_shares'
      return render :text => @res_data_hash['xml'].to_json
    elsif params[:from] == 'auto_send_bonus'
      return render :text => @res_data_hash['xml']
    end
    render 'send_bonus'
  end

  private

  def arr_paginate arr, per_page = 50
    page_numbers = per_page
    pages_count = arr.length % page_numbers == 0 ? arr.length / page_numbers : arr.length / page_numbers + 1
    pages = []
    pages_count.times do |num|
      pages << arr.slice((page_numbers * num)...(page_numbers * (num + 1)))
    end
    return [pages, pages_count]
  end

end



