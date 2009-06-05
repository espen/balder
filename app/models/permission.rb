class Permission < ActiveRecord::Base
  # uncomment any of the following lines which is relevant to your application,
  # or create your own with the name of the model which acts_as_permissible.
  belongs_to :user
  
  belongs_to :role
  
  belongs_to :permissible, :polymorphic => true, :dependent => :destroy
  
  validates_presence_of :permissible_id, :permissible_type, :action
  validates_format_of :action, :with => /^[a-z_]+$/
  validates_numericality_of :permissible_id
  validates_uniqueness_of :action, :scope => [:permissible_id,:permissible_type]
  
  def to_hash
    self.new_record? ? {} : {self.action => self.granted}
  end
  
end