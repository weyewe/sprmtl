class AddMaterialCodeToMaterial < ActiveRecord::Migration
  def change
    add_column :materials, :code, :string 
  end
end
