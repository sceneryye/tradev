class CouponController < ApplicationController
	layout  'mobile'
  def index
    #render :layout=>"tairyo_new"
  end
  def lingqu
    render :layout=>"tairyo_new"
  end
  def mycoupon
    render :layout=>"tairyo_new"
  end
end
