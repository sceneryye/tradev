#encoding:utf-8

class Ecstore::51bbmallAccount < Ecstore::Base
	self.table_name = "51bbmall_account"

	attr_accessible :auth_ext_id, :login_name, :login_password,:account_type, :login_password_confirmation, :email, :mobile, :follow_imodec,:license,:current_password
	attr_accessor :license,:current_password

end