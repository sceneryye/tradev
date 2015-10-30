#encoding:utf-8
require 'digest/md5'
require 'rest-client'
require 'erb'
include ERB::Util

class Admin::BonusesController < Admin::BaseController
  def get_users
    weixin_appid = Ecstore::Supplier.where(:name => '贸威').first.weixin_appid
    weixin_appsecret = Ecstore::Supplier.where(:name => '贸威').first.weixin_appsecret
    get_access_token = RestClient.get "https://api.weixin.qq.com/cgi-bin/token?grant_type=client_credential&appid=#{weixin_appid}&secret=#{weixin_appsecret}"
    access_token = ActiveSupport::JSON.decode(get_access_token)['access_token']
    get_users_list = RestClient.get "https://api.weixin.qq.com/cgi-bin/user/get?access_token=#{access_token}&next_openid="
    users_list = ActiveSupport::JSON.decode(get_users_list)['data']['openid']

    @users_information = []
    users_list.each do |open_id|
      @users_information << ActiveSupport::JSON.decode(RestClient.get("https://api.weixin.qq.com/cgi-bin/user/info?access_token=#{access_token}&openid=#{open_id}&lang=zh_CN"))
    end
    
  end


  private

  def paginate
    page_numbers = params[page_numbers] || 50
    pages_count = self.length / pages_numbers == 0 ? self.length / pages_numbers : self.length / pages_numbers + 1
    pages = []
    pages_count.times do |num|
      pages << self.slice((page_numbe * num)...(page_numbers * (num + 1)))
    end
    return [pages, pages_count]
  end

end



