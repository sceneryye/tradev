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
    shop_params = {}
    shop_params[:member_id] = params[:member_id]
    shop_params[:organisation_id] = Ecstore::WeihuoOrganisation.where(:name => params[:organisation_name]).first.id
    shop_params[:intro] = "name=#{params[:name]}&mobile=#{params[:mobile]}"
    shop_params[:status] = '0'
    @shop = Ecstore::WeihuoShop.new(shop_params)
    if @shop.save
      redirect_to weihuo_shop_path
    else
      render 'new'
    end

  end

  def edit
  end

  def update
  end

  
end