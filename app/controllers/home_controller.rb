#encoding:utf-8
class HomeController < ApplicationController
  before_filter :find_user
	# layout 'magazine'
	layout 'standard'

	
	def index
		@title = "trade-V 跨境贸易直通车"
		@suppliers = Ecstore::Supplier.where(:recommend=>1)
	  	@galleries = Ecstore::Teg.where(:tag_type=>"gallery")	
	  	@i = 1  	
		@home = Ecstore::Home.where(:supplier_id=>nil).last
		if signed_in?
		    redirect_to params[:return_url] if params[:return_url].present?
		end

		return render :layout=>'new'

		respond_to do  |format|
	        format.mobile { render :layout=> 'msite'}
	    end
	end

	def blank
		@return_url = params[:return_url]
		render :layout=>nil
	end

	def topmenu
		render :layout=>nil
	end
	
	def subscription_success
		@title = "trade-V 跨境贸易直通车"
	end

end
