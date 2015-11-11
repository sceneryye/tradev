# encoding:utf-8

module Admin
  class WeihuosController < Admin::BaseController
    before_filter :authorize_admin!

      #orders list
      def index


        @orders_nw = Ecstore::Order.where("shop_id>0 and shop_id<>48 and order_id>=20151110174181").order("createtime desc")
        @order_ids = @orders_nw.pluck(:order_id)

        @orders = @orders_nw.paginate(:page=>params[:page],:per_page=>20)
      end

      def goods
        @goods = Ecstore::Good.where(:supplier_id=>10).paginate(:page=>params[:page],:per_page=>20)
      end

      def organisations
        @organisations = Ecstore::WeihuoOrganisation.paginate(:page=>params[:page],:per_page=>20)

      end

      def employees
        @employees = Ecstore::WeihuoEmployee.paginate(:page=>params[:page],:per_page=>20)
      end

      def shops
        @shops = Ecstore::WeihuoShop.paginate(:page=>params[:page],:per_page=>20)
      end

      def shares
        @shares = Ecstore::WeihuoShare.paginate(:page=>params[:page],:per_page=>20)
        if params[:code] == 'success'
          share = Ecstore::WeihuoShare.where(:order_id => params[:order_id]).first
          share.update_attribute(:status, 1)
          return render :text => 'success'
        elsif params[:code] == 'fail'
          share = Ecstore::WeihuoShare.where(:order_id => params[:order_id]).first
          share.update_attribute(:return_message, ActiveSupport::JSON.decode(params[:return_message]))
        end
      end
      def clients
        @clients = Ecstore::Account.where("shop_id>0").paginate(:page=>params[:page],:per_page=>20)

      end


    end

  end
