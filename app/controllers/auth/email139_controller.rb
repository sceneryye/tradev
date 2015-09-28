#encoding:utf-8
require 'digest/md5'
require 'hashie'
require 'pp'
class Auth::Email139Controller < ApplicationController
	skip_before_filter :authorize_user!

	def index 
		shop_id = 48
		auth_ext = Ecstore::AuthExt.find_by_id(cookies.signed[:_auth_ext].to_i) if cookies.signed[:_auth_ext]
		session[:from] = "external_auth"
		
		if auth_ext&&!auth_ext.expired?&&auth_ext.provider == 'email139'
			if auth_ext.account.nil?
				cookies.delete :_auth_ext		
			#	redirect_to  Email139.authorize_url
			else
				sign_in(auth_ext.account)
				return redirect_to "/mobile/#{shop_id}/shop"
			end		
		end

		sid = params[:sid] 
		#return :text=>sid

		timestamp = Time.now.to_i - Time.parse('2000-01-01').to_i + 10

		xml_hash={}
		xml_hash[:SessionKey] = sid
		xml_hash[:ComeFrom] = 'trade_v' #'test'
		xml_hash[:TimeStamp] = timestamp
		key = 'cd3800aefa927547' #'123456'

	    unsign = xml_hash.collect{|key,val| "#{val}"}.join('') + key
	    xml_hash[:Skey]  = Digest::MD5.hexdigest(unsign).upcase

 		xml =  xml_hash.to_xml(:root=>"RequestData",:skip_instruct=>false,:indent=>0,:dasherize => false)
 		xml = xml.sub('UTF-8','gb2312').sub(' type="integer"','')
 		#return render :text=> xml
        
      #	url = 'http://121.15.167.240:19090/SSOInterface/GetUserByKey' #测试地址
      	url = 'http://ssointerface.mail.10086.cn:8080/ssointerface/GetUserByKey'
     	RestClient.get(url)
      	res_data = RestClient.post url , xml , {:content_type => :xml}
      	res_data_xml = res_data.force_encoding('gb2312').encode
      	res_data_hash = Hash.from_xml(res_data_xml)
    	#return render :text=>res_data_hash

	    if res_data_hash['ResponseData']['RetCode']=='000'

	    	#验证返回
	      	unsign_hash = Hash.send :[],  res_data_hash['ResponseData'].select{ |key,val| val.present? && key!='Skey'}
	        unsign = unsign_hash.collect do |key,val| 	"#{val}" end.join("") + key
	        #return render :text=>unsign
	        if Digest::MD5.hexdigest(unsign).upcase != res_data_hash['ResponseData']['Skey']
	        	return render :text=>'返回数据未通过验证'
	        end
	    	
	        user_number =res_data_hash['ResponseData']['UserNumber']
			return redirect_to "/auth/email139/#{sid}/callback?timestamp=#{res_data_hash['ResponseData']['TimeStamp']}&user_number=#{user_number}"
	        # 登录或注册
	    else
	    	message = res_data_hash['ResponseData']['RetCode']+':'
	    	case res_data_hash['ResponseData']['RetCode']
			when  '001'
				message +='用户登录查询失败（表示用户不在线）' 
			when '101'
				message += '参数不全'
			when '102'
				message +='Skey签名无效'  
			when '103'  
				message +='时间戳超时'
			when '104'  
				message +='ComeFrom非法'
			when '105'  
				message +='请求参数超过规定的长度'
			when '107'	
				message +='IP非法'
			when '201'  
				mesage +='服务器忙'
			else # '999'  
				message +='未知错误'			
			end
			
			return render :text=>message
	    end	   
 

	end

	def callback

		return redirect_to(site_path) if params[:error].present?	   
		shop_id =48

	    return_url= session[:return_url]
	    session[:return_url]=''
		return_url ="/mobile/#{shop_id}/shop"
	  
		
		#token = Email139.request_token(params[:code])
		sid = params[:id]
		user_number = params[:user_number]
		request_time = Time.now.to_i
		expires_in = 7200
		       

		auth_ext = Ecstore::AuthExt.where(:provider=>"email139",
						:uid=>sid).first_or_initialize(
						:access_token=>sid,
						:expires_at=>expires_in + Time.now.to_i,
						:expires_in=>expires_in)



		if auth_ext.new_record? || auth_ext.account.nil? || auth_ext.account.user.nil?
			# client = Email139.new(:access_token=>sid,:expires_at=>expires_in + Time.now.to_i)
			# auth_user = client.get('users/show.json',:uid=>sid)

			# logger.info auth_user.inspect
	        login_name = sid
			check_user = Ecstore::Account.find_by_login_name(login_name)
			
			login_name = "#{login_name}_#{rand(9999)}" if check_user

			now = Time.now

			@account = Ecstore::Account.new  do |ac|
				#account
				ac.login_name = login_name
				ac.login_password = '123456'
		  		ac.account_type ="member"
		  		ac.createtime = now.to_i
		  		ac.auth_ext = auth_ext

        		ac.supplier_id = 78  #贸威客户
	  		end

	  		Ecstore::Account.transaction do
  				if @account.save!(:validate => false)
		  			@user = Ecstore::User.new do |u|
			  			u.member_id = @account.account_id
			  			u.email = "#{user_number}@139.com"
			  			u.mobile = user_number
			  			u.source = "email139"
			  			u.member_lv_id = 1
			  			u.cur = "CNY"
			  			u.reg_ip = request.remote_ip			  			
			  			
			  			u.regtime = now.to_i
			  		end
		  			@user.save!(:validate=>false)

		  			sign_in(@account,'1')
		  		end
	  		end

	  		shop_id = 48
	  		shop_client = Ecstore::ShopClient.where(:member_id=>@account.account_id,:shop_id=>shop_id)
	        if shop_client.size ==0
	          Ecstore::ShopClient.new do |sc|
	            sc.member_id = @account.account_id
	            sc.shop_id = shop_id
	          end.save
	        end
		else
			
			sign_in(auth_ext.account,'1')
			return render :text=>auth_ext.account

		end



	    redirect_to return_url

		#rescue
		#	redirect_to(site_path)
	end

	def cancel
	end
end