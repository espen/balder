class <%= role_model_name %> < ActiveRecord::Base
  has_many :<%= role_membership_model_file_name %>s, :as => :roleable, :dependent => :destroy
  has_many :<%= role_model_file_name %>s, :through => :<%= role_membership_model_file_name %>s, :source => :<%= role_model_file_name %>
  
  has_many :roleables, :class_name => "<%= role_membership_model_name %>", :foreign_key => "<%= role_model_file_name %>_id", :dependent => :destroy
  has_many :sub<%= role_model_file_name %>s, :through => :roleables, :source => :roleable, :source_type => '<%= role_model_name %>'
  #has_many :users, :through => :roleables, :source => :roleable, :source_type => 'User'
  
  validates_uniqueness_of :name
  
  acts_as_permissible
end