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

		@recommend_suppliers = []
		@promotion = []
		Ecstore::Promotion.where("field_name = 'bn'").each do |promotion|
			recommend_suppliers = Ecstore::Supplier.where(:name => promotion.name).first
			if recommend_suppliers.present?
				@recommend_suppliers << recommend_suppliers
				@promotion << promotion
			end
		end
		@recommend_suppliers.shuffle!

		@recommend_goods = []
		@promotion.each do |promotion|
			promotion.field_vals.each do |val|
				@recommend_goods << Ecstore::Good.where(:bn => val).first
			end
		end
		@recommend_goods = @recommend_goods.shuffle[0..5]
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
