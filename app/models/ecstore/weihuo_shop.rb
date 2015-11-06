#encoding:utf-8
class Ecstore::WeihuoShop < Ecstore::Base
  self.table_name  = 'weihuo_shops'
  self.accessible_all_columns
  #attr_accessible :organisation_id

  belongs_to :weihuo_organisation,:foreign_key=>"weihuo_organisation_id"

end