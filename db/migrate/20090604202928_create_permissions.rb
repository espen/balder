class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table "permissions", :force => true do |t|
      t.integer :permissible_id
      t.string :permissible_type
      t.string :action
      t.boolean :granted

      t.timestamps
    end
  end

  def self.down
    drop_table "permissions"
  end
end