#encoding:utf-8
class Ecstore::WeihuoOrganisation < Ecstore::Base
  self.table_name  = 'weihuo_organisations'
  self.accessible_all_columns

  has_many :weihuo_employees,:foreign_key=>"weihuo_organisation_id"
  has_many :weihuo_shops,:foreign_key=>"weihuo_organisation_id"

end