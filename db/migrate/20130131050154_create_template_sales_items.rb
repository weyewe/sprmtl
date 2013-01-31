class CreateTemplateSalesItems < ActiveRecord::Migration
  def change
    create_table :template_sales_items do |t|
      t.string :code 
      t.timestamps
    end
  end
end
