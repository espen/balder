class AddFileToPhoto < ActiveRecord::Migration
  def self.up
    add_column :photos, :file, :string
  end

  def self.down
    remove_column :photos, :file
  end
end
