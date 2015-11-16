 
 class Store::OrderAttachmentsController < ApplicationController
  before_filter :find_user
  layout "standard"

    def new
       @attachment = Ecstore::OrderAttachment.new
       render :layout =>"tradev"
    end

    def create    
      uploaded_io = params[:file]
      if !uploaded_io.blank?
        extension = uploaded_io.original_filename.split('.')
        filename = "#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.#{extension[-1]}"
        #filepath = "#{PIC_PATH}/user_photos/#{filename}"
        filepath = "/root/pics/images/order_attachment/#{filename}"
        File.open(filepath, 'wb') do |file|
          file.write(uploaded_io.read)
        end
        # params[:user].merge!(:photo=>"/images/order_attachment/#{filename}")
        

        @attachment = Ecstore::OrderAttachment.new do |attachment|
          attachment.url = filepath
          attachment.member_id =@user.member_id
          attachment.cart_obj_ident = params[:cart_obj_ident]
        end.save

        redirect_to "/orders/new?attachment=#{@attachment.id}"

      else
        @user = Ecstore::Member.find(@user.member_id)

      end
    end
end