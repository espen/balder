class Role < ActiveRecord::Base
  has_many :role_memberships, :as => :roleable, :dependent => :destroy
  has_many :roles, :through => :role_memberships, :source => :role
  
  has_many :roleables, :class_name => "RoleMembership", :foreign_key => "role_id", :dependent => :destroy
  has_many :subroles, :through => :roleables, :source => :roleable, :source_type => 'Role'
  has_many :users, :through => :roleables, :source => :roleable, :source_type => 'User'
  
  validates :name, :presence => true, :uniqueness => true
  
  acts_as_permissible
end