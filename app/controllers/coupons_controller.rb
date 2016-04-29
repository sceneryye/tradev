class CouponsController < ApplicationController
	layout  'mobile'
  	def index
		@coupons = Ecstore::NewCoupon.where(:enable=>1).order("created_at asc")
	end

	def show
		@coupon = Ecstore::NewCoupon.find_by_id(params[:id])
		goods_bn = @coupon.condition_val.to_s.sub('[','').sub(']','')
		@goods = Ecstore::Good.where("bn in (#{goods_bn})")
	end

	def get
		coupon_id = params[:id]
	    @coupon = Ecstore::NewCoupon.where("id=#{coupon_id} and enable=true and end_at>?", Time.current)
	    if @coupon
	    	Ecstore::UserCoupon.new do |user_coupon|
	    		user_coupon.member_id = @user.member_id
	    		user_coupon.coupon_id = @coupon.first.id
	    		user_coupon.coupon_code = @coupon.first.coupon_prefix
	    	end.save


		    redirect_to '/member/coupons?platform=mobile'
		else
			redirect_to 'coupons'
		end
	end
	def mycoupon
	    render :layout=>"tairyo_new"
	end
end
