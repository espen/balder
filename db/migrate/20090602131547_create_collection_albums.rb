class CreateCollectionAlbums < ActiveRecord::Migration
  def self.up
    create_table :collection_albums do |t|
      t.references :collection
      t.references :album

      t.timestamps
    end
  end

  def self.down
    drop_table :collection_albums
  end
end
