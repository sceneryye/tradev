#encoding:utf-8

class Weihuo::GoodsController < ApplicationController

  layout "weihuo"

  def index

    
  end

  def try
    @data = params[:res_data_hash]
    render :layout => 'standard'
  end

  def show
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end
  
end