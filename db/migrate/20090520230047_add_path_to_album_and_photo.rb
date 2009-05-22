class AddPathToAlbumAndPhoto < ActiveRecord::Migration
  def self.up
    add_column :albums, :path, :text
    add_column :photos, :path, :text
  end

  def self.down
    remove_column :albums, :path
    remove_column :photos, :path
  end
end
