class CreatePhotoTags < ActiveRecord::Migration
  def self.up
    create_table :photo_tags do |t|
      t.references :tag
      t.references :photo
      t.timestamps
    end
  end

  def self.down
    drop_table :photo_tags
  end
end
