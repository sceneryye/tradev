# encoding:utf-8

module Admin
    class WeihuosController < Admin::BaseController

      #orders list
      def index
        @orders = Ecstore::Order.where("shop_id>0")
      end
     
      def goods
        @goods = Ecstore::Good.where(:supplier_id=>10)
      end

      def organisations
        @organisations = Ecstore::WeihuoOrganisation.all

      end

      def employees
        @employees = Ecstore::WeihuoEmployee.all
      end

      def shops
        @shops = Ecstore::WeihuoShop.all
      end

      def shares
        @shares = Ecstore::WeihuoShare.all
      end

      def clients
        @clients = Ecstore::User.where("shop_id>0")

      end


    end
    
end
