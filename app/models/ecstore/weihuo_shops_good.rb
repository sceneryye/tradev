#encoding:utf-8
class Ecstore::WeihuoShopsGood < Ecstore::Base
  self.table_name  = 'weihuo_shops_goods'
  self.accessible_all_columns
  #attr_accessible :organisation_id
  belongs_to :weihuo_shop
  belongs_to :good


end