class CreatePages < ActiveRecord::Migration
  def up
    create_table :shoppe_pages do |t|
      t.string :name
      t.string :permalink
      t.text :text
      t.boolean :info
      t.string :title
    end
  end
  
  def down
    drop_table :shoppe_pages
  end
end
