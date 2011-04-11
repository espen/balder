class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= role_model_file_name %>s do |t|
      t.string :name

      <% unless options[:skip_timestamps] %>t.timestamps<% end %>
    end
  end

  def self.down
    drop_table :<%= role_model_file_name %>s
  end
end