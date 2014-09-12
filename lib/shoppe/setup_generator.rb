require 'rails/generators'
module Shoppe
  class SetupGenerator < Rails::Generators::Base
    
    def create_route
      route 'mount Shoppe::Engine => "/shoppe"'
      route "get 'product/:permalink' => 'products#show', :as => 'product'"
      route "post 'product/:permalink' => 'products#buy'"
      route "root :to => 'products#index'"
      route "get 'basket' => 'orders#show'"
      route "delete 'basket' => 'orders#destroy'"
      route "match 'checkout' => 'orders#checkout', :as => 'checkout', :via => [:get, :patch]"
      route "match 'checkout/pay' => 'orders#payment', :as => 'checkout_payment', :via => [:get, :post]"
      route "match 'checkout/confirm' => 'orders#confirmation', :as => 'checkout_confirmation', :via => [:get, :post]"
    end

    def create_initializer_file
      create_file "app/controllers/products_controller.rb", <<-eos 
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
