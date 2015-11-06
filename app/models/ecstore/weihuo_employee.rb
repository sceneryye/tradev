#encoding:utf-8
class Ecstore::WeihuoEmployee < Ecstore::Base
  self.table_name  = 'weihuo_employees'
  self.accessible_all_columns

  belongs_to :weihuo_organisation,:foreign_key=>"weihuo_organisation_id"

end