class CreateCampus < ActiveRecord::Migration
 def self.up
   create_table :campus, :id => false do |t|
     t.integer :ogr_fid
     t.geometry :shape
     t.string :name
     t.string :description

   end
   add_index :campus, :shape, :spatial => true
 end

 def self.down
   drop_table :campus
 end
end