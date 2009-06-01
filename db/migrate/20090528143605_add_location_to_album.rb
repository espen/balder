class AddLocationToAlbum < ActiveRecord::Migration
  def self.up
    add_column :albums, :address, :string
    add_column :albums, :longitude, :float
    add_column :albums, :latitude, :float
  end

  def self.down
    remove_column :albums, :latitude
    remove_column :albums, :longitude
    remove_column :albums, :address
  end
end
