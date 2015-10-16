class CouponController < ApplicationController
	layout  'mobile'
  	def index
		@coupons = Ecstore::NewCoupon.where(:enable=>1).order("created_at asc")
	end

	def show
		@coupon = Ecstore::NewCoupon.find_by_id(params[:id])
	end

	def create
		@coupons = Ecstore::NewCoupon.where(:enable=>1).order("created_at asc")
	end

	def lingqu
	    render :layout=>"tairyo_new"
	end
	def mycoupon
	    render :layout=>"tairyo_new"
	end
end
