#encoding:utf-8
class Admin::ExpressRulesController < Admin::BaseController


  def index
     @express_rules = Ecstore::ExpressRule.paginate(:page => params[:page], :per_page => 20).order("id DESC")

  end

  def edit
    @express_rule = Ecstore::ExpressRule.find(params[:id])
    @action_url =  admin_express_rule_path(@express_rule)
    @method = :put
  end

 
  def new
    @express_rule = Ecstore::ExpressRule.new
    @action_url =  admin_express_rules_path
    @method = :post
  end


  def create

    @express_rule = Ecstore::ExpressRule.new params[:express_rule]
    if @express_rule.save
      redirect_to admin_express_rules_url
    else
      @action_url =  admin_express_rules_path
      @method = :post
      render :new
    end
  end

  def update
    @express_rule = Ecstore::ExpressRule.find(params[:id])
    if @express_rule.update_attributes(params[:express_rule])
      redirect_to admin_express_rules_url
    else
      @action_url =  admin_express_rule_path(@express_rule)
      @method = :put
      render :edit
    end
  end

  def destroy
    @brand  = Ecstore::Footer.find(params[:id])
    @brand.destroy
    redirect_to admin_brand_adms_url
  end


  def destroy
    @express_rule = Ecstore::ExpressRule.find(params[:id])
    @express_rule.destroy
    redirect_to admin_express_rules_path
  end





end
