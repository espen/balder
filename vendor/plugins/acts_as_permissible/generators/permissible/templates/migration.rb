class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.integer :permissible_id
      t.string :permissible_type
      t.string :action
      t.boolean :granted

      <% unless options[:skip_timestamps] %>t.timestamps<% end %>
    end
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end