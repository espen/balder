class AddLocationToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :longitude, :float
    add_column :photos, :latitude, :float
  end

  def self.down
    remove_column :photos, :latitude
    remove_column :photos, :longitude
  end
end
