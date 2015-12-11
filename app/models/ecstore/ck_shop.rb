#encoding:utf-8
class Ecstore::WeihuoShop < Ecstore::Base
  self.table_name  = 'ck_shops'
  self.accessible_all_columns
  self.primary_key = 'shop_id'
  
  belongs_to :ck_organisation,:foreign_key=>"ck_organisation_id"
  has_many :orders, :foreign_key=>"shop_id"

  has_many :ck_shops_goods
  has_many :good, :through => :ck_shops_good
  has_one :ck_employee, :foreign_key => 'shop_id'
  belongs_to :user, :foreign_key=>"member_id"


end