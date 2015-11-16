# encoding:utf-8

module Admin
    class AccountssController < Admin::BaseController

      def index
        @total_member = Ecstore::Member.count()
        if (current_admin.login_name=="sale_0001")
          @members = Ecstore::Member.where(:member_id=>"2455").paginate(:page => params[:page], :per_page => 20).order("member_id DESC")
        elsif (current_admin.login_name=="sale_0002")
          @members = Ecstore::Member.where(:member_id=>"2456").paginate(:page => params[:page], :per_page => 20).order("member_id DESC")
        else
          @members = Ecstore::Member.paginate(:page => params[:page], :per_page => 20).order("member_id DESC")
        end

        @column_data = YAML.load(File.open(Rails.root.to_s+"/config/columns/member.yml"))

        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @members }
        end
      end

      def show
      end

      def edit
        @member = Ecstore::Member.find(params[:id])
      end

      def updateInfo
        @member = Ecstore::Member.find(params[:id])
        @member.mobile = params[:ecstore_member][:mobile]
        @member.email = params[:ecstore_member][:email]
        @member.member_lv_id = params[:ecstore_member][:member_lv_id]
        if @member.advance != params[:ecstore_member][:advance].to_i
          @adv_log ||= Logger.new('log/adv.log')
          @adv_log.info("member id: "+@member.member_id.to_s+"--advance:"+@member.advance.to_s+"=>"+params[:ecstore_member][:advance])
          @member.advance = params[:ecstore_member][:advance]
        end
        @member.save
        redirect_to admin_members_path
      end

      def info
        @member = Ecstore::Member.find(params[:id])
      end

    


      def columns
        
      end

      def export
        fields =  params[:fields]
        if params[:member][:select_all].to_i > 0
           members = Ecstore::Member.all  #找出所有数据
        else
           members = Ecstore::Member.find(:all,:conditions => ["member_id in (?)",params[:ids]])
        end
        content = Ecstore::Member.export(fields,members)  #调用export方法
        send_data(content, :type => 'text/csv',:filename => "member_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv")
      end

   
    end
    
end
