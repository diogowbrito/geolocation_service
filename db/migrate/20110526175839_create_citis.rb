class CreateCitis < ActiveRecord::Migration
 def self.up
   create_table :citis, :id => false do |t|
     t.integer :ogr_fid
     t.geometry :shape
     t.string :name
     t.string :description


     t.timestamps
   end
   add_index :citis, :shape, :spatial => true
 end

 def self.down
   drop_table :campus
 end
end