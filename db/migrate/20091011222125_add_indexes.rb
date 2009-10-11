class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :albums, :id, :unique => true
    add_index :collections, :id, :unique => true
    add_index :photos, :id, :unique => true
    add_index :tags, :id, :unique => true

    add_index :collection_albums, :collection_id
    add_index :collection_albums, :album_id
    add_index :photos, :album_id
    add_index :photo_tags, :tag_id
    add_index :photo_tags, :photo_id
  end

  def self.down
    remove_index :albums, :id
    remove_index :collections, :id
    remove_index :photos, :id
    remove_index :tags, :id

    remove_index :collection_albums, :collection_id
    remove_index :collection_albums, :album_id
    remove_index :photos, :album_id
    remove_index :photo_tags, :tag_id
    remove_index :photo_tags, :photo_id
  end
end
