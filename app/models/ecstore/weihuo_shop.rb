#encoding:utf-8
class Ecstore::WeihuoShop < Ecstore::Base
  self.table_name  = 'weihuo_shops'
  self.accessible_all_columns
  self.primary_key = 'shop_id'
  
  belongs_to :weihuo_organisation,:foreign_key=>"weihuo_organisation_id"
  has_many :orders, :foreign_key=>"shop_id"

  has_many :weihuo_shops_goods
  has_many :good, :through => :weihuo_shops_good
  has_one :weihuo_employee, :foreign_key => 'shop_id'
  belongs_to :user, :foreign_key=>"member_id"


end