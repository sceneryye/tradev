#encoding:utf-8
class Admin::ExpressRulesController < Admin::BaseController


  def show

  end

  def index
     @express_rules = Ecstore::ExpressRule.paginate(:page => params[:page], :per_page => 20).order("time DESC")

  end

  def edit
    @express_rule = Ecstore::ExpressRule.find(params[:id])
  end

 
  def create
      @express_rule = Ecstore::ExpressRule.new
      @goodcat.cat_name = params[:express_rule][:cat_name]
      @goodcat.type_id = params[:express_rule][:type]
      @goodcat.parent_id =params[:express_rule][:cat]
      path = Ecstore::ExpressRule.find(params[:express_rule][:cat]).cat_path
      @goodcat.cat_path = path + params[:express_rule][:cat] + ","

      if @goodcat.save
        redirect_to edit_admin_express_rule_url(@express_rule)
      else
        render "new"
      end
  end

  def update
    @express_rule = Ecstore::ExpressRule.find(params[:id])
    if @express_rule.update_attributes(params[:ecstore_express_rule])
      redirect_to edit_admin_express_rule_url(@express_rule)
    else
      render action: "edit"
    end
  end

  def destroy
    @express_rule = Ecstore::ExpressRule.find(params[:id])
    @express_rule.destroy
    redirect_to admin_express_rules_path
  end





end
