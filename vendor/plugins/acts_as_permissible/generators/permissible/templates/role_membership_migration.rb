class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= role_membership_model_file_name %>s do |t|
      t.integer :roleable_id
      t.string :roleable_type
      t.integer :<%= role_model_file_name %>_id

      <% unless options[:skip_timestamps] %>t.timestamps<% end %>
    end
  end

  def self.down
    drop_table :<%= role_membership_model_file_name %>s
  end
end