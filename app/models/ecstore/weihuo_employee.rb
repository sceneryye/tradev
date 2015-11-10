#encoding:utf-8
class Ecstore::WeihuoEmployee < Ecstore::Base
  self.table_name  = 'weihuo_employees'
  self.accessible_all_columns

  belongs_to :weihuo_organisation,:foreign_key=>"weihuo_organisation_id"
  belongs_to :weihuo_shop, :foreign_key => 'shop_id'
  belongs_to :user, :foreign_key=>'member_id'

end