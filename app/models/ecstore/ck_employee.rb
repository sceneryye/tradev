#encoding:utf-8
class Ecstore::WeihuoEmployee < Ecstore::Base
  self.table_name  = 'ck_employees'
  self.accessible_all_columns

  belongs_to :ck_organisation,:foreign_key=>"ck_organisation_id"
  belongs_to :ck_shop, :foreign_key => 'shop_id'
  belongs_to :user, :foreign_key=>'member_id'

end