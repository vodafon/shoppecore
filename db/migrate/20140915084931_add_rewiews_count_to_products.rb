class AddRewiewsCountToProducts < ActiveRecord::Migration
  def up
    add_column(:shoppe_products, :reviews_count, :integer, :default => 0)
    add_index(:shoppe_products, [:reviews_count])
  end
  def down
    remove_index(:shoppe_products, [:reviews_count])
    remove_column(:shoppe_products, :reviews_count, :integer, :default => 0)
  end
end
