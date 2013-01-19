class AddTapToProductionHistory < ActiveRecord::Migration
  def change
    add_column  :production_histories, :ok_tap_weight, :decimal, :default => 0,  :precision => 7, :scale => 2
    add_column  :production_histories, :repairable_tap_weight, :decimal, :default => 0, :precision => 7, :scale => 2 
  end
end
