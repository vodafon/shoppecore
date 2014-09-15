module Shoppe
  class ProductsController < Shoppe::ApplicationController
  
    before_filter { @active_nav = :products }
    before_filter { params[:id] && @product = Shoppe::Product.root.find(params[:id]) }
  
    def index
      @products = Shoppe::Product.root.where("reviews_count > ?", 0).includes(:stock_level_adjustments, :product_category, :variants).order("reviews_count DESC").group_by(&:product_category).sort_by { |cat,pro| cat.products.count }
    end
  
    def new
      @product = Shoppe::Product.new
    end
  
    def create
      @product = Shoppe::Product.new(safe_params)
      if @product.save
        redirect_to :products, :flash => {:notice => "Product has been created successfully"}
      else
        render :action => "new"
      end
    end
  
    def edit
    end
  
    def update
      if @product.update(safe_params)
        redirect_to [:edit, @product], :flash => {:notice => "Product has been updated successfully"}
      else
        render :action => "edit"
      end
    end
  
    def destroy
      @product.destroy
      redirect_to :products, :flash => {:notice => "Product has been removed successfully"}
    end
    
    private
  
    def safe_params
      params[:product].permit(:product_category_id, :name, :sku, :permalink, :title, :description, :short_description, :keywords, :weight, :price, :cost_price, :tax_rate_id, :stock_control, :image, :active, :featured, :in_the_box, :product_attributes_array => [:key, :value, :searchable, :public])
    end
  
  end
end
