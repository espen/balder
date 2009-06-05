class CreateRoleMemberships < ActiveRecord::Migration
  def self.up
    create_table :role_memberships do |t|
      t.integer :roleable_id
      t.string :roleable_type
      t.integer :role_id

      t.timestamps
    end
  end

  def self.down
    drop_table :role_memberships
  end
end