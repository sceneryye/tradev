require 'digest/md5'
class Ecstore::Coupon < Ecstore::Base
	self.table_name = "sdb_b2c_coupons"

	belongs_to :rule_order,:foreign_key=>"rule_id"

	COUPON_COUNT_LEN = 5
	COUPON_ENCRYPT_LEN = 5

	def make_coupon_code
		no = self.cpns_gen_quantity + 1
		prefix = self.cpns_prefix
		key  = self.cpns_key

		no = no.to_s(36).upcase
		if no.size < COUPON_COUNT_LEN
			no = "0"*(COUPON_COUNT_LEN - no.size) + no
		end
		check_code = Digest::MD5.hexdigest("#{key}#{no}#{prefix}")[0..(COUPON_ENCRYPT_LEN-1)].upcase
		"#{prefix}#{check_code}#{no}"
	end

	def expired?
		now = Time.zone.now.to_i
		!(self.rule_order.from_time <= now && self.rule_order.to_time >= now)
	end
end