#encoding:utf-8

class Weihuo::ShopsController < ApplicationController

  layout "standard"

  # 所有店铺展示
  def index


  end

  def show
  end

  # 申请店铺
  def new
    @organisations = Ecstore::WeihuoOrganisation.all
    organisation = Ecstore::WeihuoOrganisation.where(:name => params[:organisation_name])
    @employees = Ecstore::WeihuoEmployee.where(:weihuo_organisation_id => organisation.first.id) if organisation.present?
    @shop = Ecstore::WeihuoShop.new
  end

  def create
  end

  def edit
  end

  def update
  end

  
end