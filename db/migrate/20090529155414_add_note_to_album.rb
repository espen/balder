class AddNoteToAlbum < ActiveRecord::Migration
  def self.up
    add_column :albums, :note, :text
  end

  def self.down
    remove_column :albums, :note
  end
end
