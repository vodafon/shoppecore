module Shoppe
  class Page < ActiveRecord::Base
  
    self.table_name = 'shoppe_pages'
  
    validates :name, :presence => true
    validates :permalink, :presence => true, :uniqueness => true
    validates :text, :presence => true
    
    # Before validation, set the permalink if we don't already have one
    before_validation { self.permalink = self.name.parameterize if self.permalink.blank? && self.name.is_a?(String) }

    # All active products
    scope :info, -> { where(:info => true) }
  end
end
