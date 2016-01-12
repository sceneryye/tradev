# encoding:utf-8
require "iconv"
require 'axlsx'

module Admin
  class WeihuosController < Admin::BaseController

      skip_before_filter :require_permission!
      skip_before_filter :verify_authenticity_token,:only=>[:batch]

    def import(options={:encoding=>"GB18030:UTF-8"})
        file = params[:employees][:file].tempfile
        book = Spreadsheet.open(file)
        pp "starting import ..."
        sheet = book.worksheet(0)

        @employees = Ecstore::WeihuoEmployee.new
        @organisations = Ecstore::WeihuoOrganisation.new
        sheet.each_with_index do |row,i|
           
            if i >= 0

                if row[3].blank? #姓名为空
                        @employees = Ecstore::WeihuoEmployee.new
                    @employees.name= row[0]
                    @employees.mobile= row[1].to_i
                    if row[2]>0
                    @employees.weihuo_organisation_id=row[2] 
                    else
                    return  render :text=>"人员导入表为空或者格式错误。Line: #{i}"
                    end
                   @employees.save!
            
                else
                 @organisations = Ecstore::WeihuoOrganisation.new
                  @organisations.name=row[0]
                  @organisations.parent_id=row[1]
                  @organisations.path=row[2]
                  @organisations.share=row[3]
                  @organisations.level=row[4]
                  @organisations.address=row[5]
                  @organisations.tel=row[6].to_i
                  @organisations.manager=row[7]
                  @organisations.save!
                end
            end   
         end
        redirect_to admin_weihuos_path
      end
      def export
  


        if(params[:batch].nil?)
          flash[:alert] = '请选择需要导出的表'
        id =[0]
        else
          id =  params[:batch][:employees_id] || []
        end


        if params[:member][:select_all].to_i > 0
         #找出所有数据
          conditions = "employees_id in ("+params[:all_employees_id]+")"
        else
          conditions = { :employees_id=>id }
        end
     
          employees = Ecstore::WeihuoEmployee.all
          organisations=Ecstore::WeihuoOrganisation.all
          package = Axlsx::Package.new
          workbook = package.workbook


          workbook.styles do |s|
          head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,
                                                                        :vertical => :center}
          employees_cell = s.add_style :b=>true,:bg_color=>"FFFACD", :sz => 10, :alignment => {:vertical => :center}

          workbook.add_worksheet(:name => "organisation") do |sheet|

          sheet.add_row ['id',"姓名","员工手机","所属机构id号","网点名","上级","分成","级别","负责人", "负责人电话","地址"],:style=>head_cell
                     
    
            row_count=0

            employees.each do |employee|

              employeeid=employee.id
              employeename=employee.name
              employeemobile=employee.mobile
              weihuo_organisation_id=employee.weihuo_organisation_id
              sheet.add_row [employeeid,employeename,employeemobile,weihuo_organisation_id,nil,nil,nil,nil,nil,nil,nil]
              row_count +=1
            end

              organisations.each do |organisation|
             
           
               organisationname =organisation.name
               organisationpath=organisation.path
               organisationshare=organisation.share
               organisationlevel=organisation.level
               organisationmanager=organisation.manager
               organisationtel=organisation.tel
               organisationaddress=organisation.address
                 sheet.add_row [nil,nil,nil,nil,organisationname,organisationpath,organisationshare,organisationlevel,organisationmanager,organisationtel,organisationaddress]
              end
           
        end
        send_data package.to_stream.read,:filename=>"weihuos_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
end
        #content = Ecstore::Good.export_cvs(fields,goods) #导出cvs
        # MS Office 需要转码
        # send_data(content, :type => 'text/csv',:filename => "goods_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv")

        # content = Ecstore::Good.export_xls(fields,goods) #导出excel
        # send_data(content, :type => "text/excel;charset=utf-8; header=present",:filename => "goods_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xls")
    
end
 def downgood

        goods = Ecstore::Good.where(:supplier_id=>10)
   
        package = Axlsx::Package.new
        workbook = package.workbook
        workbook.styles do |s|
          head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,
                                                                        :vertical => :center}
          goods_cell = s.add_style :b=>true,:bg_color=>"FFFACD", :sz => 10, :alignment => {:vertical => :center}
          product_cell =  s.add_style  :sz => 9

          workbook.add_worksheet(:name => "Product") do |sheet|

          sheet.add_row ["商品编号","商品名称","品牌","进货价","会员价","市场价","库存","上架", "规格","商品描述",],
                        :style=>head_cell

            row_count=0

            goods.each do |good|

              goodsBn=good.bn.to_s
              goodsName=good.name
              goodsBrand=good.brand&&good.brand.brand_name
              goodsCost=good.cost
              goodPrice=good.price
              goodMktprice=good.mktprice
              goodStore=good.store.to_i
              goodsMt =good.marketable=="true" ? "是" : "否"
              goodsspecinfo=good.spec_info
               goodsdesc=good.desc
              sheet.add_row [goodsBn,goodsName,goodsBrand,goodsCost,goodPrice,goodMktprice,goodStore,goodsMt,goodsspecinfo,goodsdesc],:style=>goods_cell,:height=> 40

              row_count +=1
              end

            end
             send_data package.to_stream.read,:filename=>"downgood_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
          end
         
      end
      #orders list
      def downorder

         orders= Ecstore::Order.where("shop_id>0 and shop_id<>48 and order_id>=20151110174181")
   
          package = Axlsx::Package.new
          workbook = package.workbook

            workbook.styles do |s|
          head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,
                                                                        :vertical => :center}
          employees_cell = s.add_style :b=>true,:bg_color=>"FFFACD", :sz => 10, :alignment => {:vertical => :center}

          workbook.add_worksheet(:name => "ordersinfo") do |sheet|

          sheet.add_row [" 订单号","会员","收货人","下单时间","订单状态","付款状态","发货状态","订单金额","店铺id","收货地址","运单号"],:style=>head_cell
                     

            row_count=0

            orders.each do |order| 
              orderid=order.order_id.to_s + " "
              memberid=order.member_id
              shipname=order.ship_name
              createdat=order.created_at
              statustext=order.status_text
              paystatustext=order.pay_status_text
              shipstatustext=order.ship_status_text
              finalamount=order.final_amount
              shopid=order.shop_id
             shipaddrs=order.ship_addr
          
              sheet.add_row [orderid,memberid,shipname,createdat,statustext,paystatustext,shipstatustext,finalamount,shopid,shipaddrs]
              row_count +=1
            end
           end
          send_data package.to_stream.read,:filename=>"weihuoorder_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
          end
      end
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
        @shares = Ecstore::WeihuoShare.paginate(:page=>params[:page],:per_page=>20).order('id desc')
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
        def search
            @template =  params[:template] || "employees"
            @view =  params[:view] || "employees"
            @layout = params[:layout] || "admin"

            @count = @employees.count
            respond_to do |format|
                format.html { render @view,:layout=> @layout }
                format.js
            end
        end
   end 
end
    
  
  