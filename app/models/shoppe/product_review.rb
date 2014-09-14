module Shoppe
  class ProductReview < ActiveRecord::Base
  
    self.table_name = 'shoppe_product_reviews'
  
    belongs_to :product, :class_name => 'Shoppe::Product'
    
  end
end
