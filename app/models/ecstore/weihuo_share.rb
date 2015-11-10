#encoding:utf-8
class Ecstore::WeihuoShare < Ecstore::Base
  self.accessible_all_columns
  
  belongs_to :order,:foreign_key=>"order_id"
  belongs_to :user, :foreign_key=>"member_id"

end