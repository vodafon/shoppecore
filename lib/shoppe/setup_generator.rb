require 'rails/generators'
module Shoppe
  class SetupGenerator < Rails::Generators::Base
    
    def create_route
      route "get 'product/:permalink' => 'products#show', :as => 'product'"
      route "post 'product/:permalink' => 'products#buy'"
      route "root :to => 'products#index'"
      route "get 'basket' => 'orders#show'"
      route "delete 'basket' => 'orders#destroy'"
      route "match 'checkout' => 'orders#checkout', :as => 'checkout', :via => [:get, :patch]"
      route "match 'checkout/pay' => 'orders#payment', :as => 'checkout_payment', :via => [:get, :post]"
      route "match 'checkout/confirm' => 'orders#confirmation', :as => 'checkout_confirmation', :via => [:get, :post]"
      route 'mount Shoppe::Engine => "/shoppe"'
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
      
      create_file "app/controllers/orders_controller.rb", <<-eos 
class OrdersController < ApplicationController
  def destroy
    current_order.destroy
    session[:order_id] = nil
    redirect_to root_path, :notice => "Basket emptied successfully."
  end

  def checkout
    @order = Shoppe::Order.find(current_order.id)
    if request.patch?
      if @order.proceed_to_confirm(params[:order].permit(:first_name, :last_name, :billing_address1, :billing_address2, :billing_address3, :billing_address4, :billing_country_id, :billing_postcode, :email_address, :phone_number))
        redirect_to checkout_confirmation_path
      end
    end
  end

  def payment
    if request.post?
      redirect_to checkout_confirmation_path
    end
  end

  def confirmation
    if request.post?
      current_order.confirm!
      session[:order_id] = nil
      redirect_to root_path, :notice => "Order has been placed successfully!"
    end
  end
end
      eos
      create_file "app/controllers/application_controller.rb", <<-eos 
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  private

  def current_order
    @current_order ||= begin
      if has_order?
        @current_order
      else
        order = Shoppe::Order.create(:ip_address => request.ip)
        session[:order_id] = order.id
        order
      end
    end
  end

  def has_order?
    !!(
      session[:order_id] &&
      @current_order = Shoppe::Order.includes(:order_items => :ordered_item).find_by_id(session[:order_id])
    )
  end

  helper_method :current_order, :has_order?
end
      eos
      create_file "app/views/layouts/application.html.erb", <<-eos 
<!DOCTYPE html>
<html>
<head>
  <title>Store</title>
  <%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>
  <%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>
  <%= csrf_meta_tags %>
</head>
<body>
  <% if has_order? %>
    <p style="border:1px solid black;padding:10px;">
    You have <%= pluralize current_order.total_items, 'item'%> in your basket which cost
    <%= number_to_currency current_order.total_before_tax %>.
    </p>
  <% end %>
  <%= link_to "View basket", basket_path %>
  <%= link_to "Checkout", checkout_path %>

<%= yield %>

</body>
</html>
      eos
      create_file "app/views/orders/_items.html.erb", <<-eos 
<table width='100%' border='1'>
  <thead>
    <tr>
      <td>Quantity</td>
      <td>Product</td>
      <td>Sub-Total</td>
      <td>Tax</td>
      <td>Total</td>
    </tr>
  </thead>
  <tbody>
    <% order.order_items.each do |item| %>
    <tr>
      <td><%= item.quantity %></td>
      <td><%= item.ordered_item.full_name %></td>
      <td><%= number_to_currency item.sub_total %></td>
      <td><%= number_to_currency item.tax_amount %></td>
      <td><%= number_to_currency item.total %></td>
    </tr>
    <% end %>

    <% if order.delivery_service %>
    <tr>
      <td></td>
      <td><%= order.delivery_service.name %></td>
      <td><%= number_to_currency order.delivery_price %></td>
      <td><%= number_to_currency order.delivery_tax_amount %></td>
      <td><%= number_to_currency order.delivery_price + order.delivery_tax_amount %></td>
    </tr>
    <% end %>

  </tbody>
  <tfoot>
    <tr>
      <td colspan='4'>Sub-Total</td>
      <td><%= number_to_currency order.total_before_tax %></td>
    </tr>
    <tr>
      <td colspan='4'>Tax</td>
      <td><%= number_to_currency order.tax %></td>
    </tr>
    <tr>
      <td colspan='4'>Total</td>
      <td><%= number_to_currency order.total %></td>
    </tr>
  </tfoot>
</table>
      eos
      create_file "app/views/orders/checkout.html.erb", <<-eos 
<h2>Checkout</h2>
<%= render 'items', :order => @order %>

<%= form_for @order, :url => checkout_path do |f| %>
  <dl>
    <dt><%= f.label :first_name, 'Name' %></dt>
    <dd><%= f.text_field :first_name %> <%= f.text_field :last_name %></dd>

    <dt><%= f.label :billing_address1, 'Address' %></dt>
    <dd><%= f.text_field :billing_address1 %></dd>
    <dd><%= f.text_field :billing_address2 %></dd>
    <dd><%= f.text_field :billing_address3 %></dd>    
    <dd><%= f.text_field :billing_address4 %></dd>
    <dd><%= f.text_field :billing_postcode %></dd>
    <dd><%= f.collection_select :billing_country_id, Shoppe::Country.ordered, :id, :name, :include_blank => true %></dd>

    <dt><%= f.label :email_address %></dt>
    <dd><%= f.text_field :email_address %></dd>

    <dt><%= f.label :phone_number %></dt>
    <dd><%= f.text_field :phone_number %></dd>

    <dd><%= f.submit 'Continue' %></dd>
  </dl>
<% end %>
      eos
      create_file "app/views/orders/confirmation.html.erb", <<-eos 
<h2>Place your order</h2>
<%= render 'items', :order => current_order %>
<%= button_to "Place order" %>
      eos
      create_file "app/views/orders/payment.html.erb", <<-eos 
<h2>Make your payment</h2>
<%= form_tag do %>
  <dl>
    <dt><%= label_tag 'card_number' %></dt>
    <dd><%= text_field_tag 'card_number' %></dd>
    <dt><%= label_tag 'expiry' %></dt>
    <dd><%= text_field_tag 'expiry' %></dd>
    <dt><%= label_tag 'security_code' %></dt>
    <dd><%= text_field_tag 'security_code' %></dd>
    <dd><%= submit_tag "Continue" %></dd>
  </dl>
<% end %>
      eos
      create_file "app/views/orders/show.html.erb", <<-eos 
<h2>Your basket</h2>
<%= render 'items', :order => current_order %>
<p><%= link_to 'Empty basket', basket_path, :method => :delete %></p>
      eos
      create_file "app/views/products/index.html.erb", <<-eos 
<h2>Products</h2>

<% @products.each do |category, products| %>
  <h3><%= category.name %></h3>
  <ul>
    <% products.each do |product| %>
    <li>
      <h4><%= link_to product.name, product_path(product.permalink) %></h4>
      <p><%= product.short_description %></p>
      <p><b>Price:</b> <%= number_to_currency product.price %></p>
    </li>
    <% end %>
  </ul>
<% end %>
      eos
      create_file "app/views/products/show.html.erb", <<-eos 
<h2><%= @product.name %></h2>

<% if @product.default_image %>
  <%= image_tag @product.default_image.path, :width => '200px', :style => "float:right" %>
<% end %>

<p><%= @product.short_description %></p>
<p>
  <b><%= number_to_currency @product.price %></b>
  <%= link_to "Add to basket", product_path(@product.permalink), :method => :post %>
</p>

<hr>
<%= simple_format @product.description %>
<hr>

<p><%= link_to "Back to list", root_path %></p>
      eos
    end
  end
end
