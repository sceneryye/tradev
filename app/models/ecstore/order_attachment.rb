class Ecstore::OrderAttachment < Ecstore::Base
	self.table_name = 'sdb_b2c_order_attachments'
	self.accessible_all_columns
	belongs_to :user, :foreign_key =>"member_id"
	belongs_to :order, :foreign_key => "order_id"
	belongs_to :cart, :foreign_key=>"cart_obj_ident"

end