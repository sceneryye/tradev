# encoding:utf-8

module Admin
    class WeihuosController < Admin::BaseController
      before_filter :authorize_admin!

      #orders list
      def index

       
        @orders_nw = Ecstore::Order.where("shop_id>0").order("createtime desc")
        @order_ids = @orders_nw.pluck(:order_id)

        @ordders = @orders_nw.paginate(:page=>params[:page],:per_page=>20)
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
      end

      def clients
        @clients = Ecstore::Account.where("shop_id>0").paginate(:page=>params[:page],:per_page=>20)

      end


    end
    
end
