class RemovePathFromPhotos < ActiveRecord::Migration
  def self.up
    remove_column :photos, :path
  end

  def self.down
  end
end
