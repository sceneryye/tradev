#encoding:utf-8
class Ecstore::WeihuoShop < Ecstore::Base
  self.table_name  = 'weihuo_shops'
  self.accessible_all_columns
  self.primary_key = 'shop_id'
  #attr_accessible :organisation_id

  belongs_to :weihuo_organisation,:foreign_key=>"weihuo_organisation_id"

  # has_many :weihuo_shops_good, :foreign_key => 'shop_id'
  # has_one :weihuo_employee, :foreign_key => 'member_id'

  belongs_to :user, :foreign_key=>"member_id"


end