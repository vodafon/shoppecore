require 'rails/generators'
module Shoppe
  class SetupGenerator < Rails::Generators::Base
    
    def create_route
      route 'mount Shoppe::Engine => "/shoppe"'
    end

    def create_initializer_file
      create_file "app/controllers/products2_controller.rb", <<-eos 
class ProductsController < ApplicationController
  def index
    @products = Shoppe::Product.root.ordered.includes(:product_category, :variants)
    @products = @products.group_by(&:product_category)
  end

  def show
    @product = Shoppe::Product.find_by_permalink(params[:permalink])
  end

  def buy
    @product = Shoppe::Product.find_by_permalink!(params[:permalink])
    current_order.order_items.add_item(@product, 1)
    redirect_to product_path(@product.permalink), :notice => "Product has been added successfuly!"
  end
end
      eos
    end
  end
end
