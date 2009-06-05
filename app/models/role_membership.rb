class RoleMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :role
  belongs_to :roleable, :polymorphic => true
  
  validates_presence_of :roleable_id, :roleable_type, :role_id
  validates_uniqueness_of :role_id, :scope => [:roleable_id, :roleable_type]
  validates_numericality_of :roleable_id, :role_id
  validates_format_of :roleable_type, :with => /^[A-Z]{1}[a-z0-9]+([A-Z]{1}[a-z0-9]+)*$/
  validate :role_does_not_belong_to_itself_in_a_loop
  
  protected
  def role_does_not_belong_to_itself_in_a_loop
    if roleable_type == "Role"
      if role_id == roleable_id
        errors.add_to_base("A role cannot belong to itself.")
      else
        if belongs_to_itself_through_other?(roleable_id, role_id)
          errors.add_to_base("A role cannot belong to a role which belongs to it.")
        end
      end
    end
  end
  
  def belongs_to_itself_through_other?(original_roleable_id, current_role_id)
    if self.class.find(:first, :select => "id", :conditions => ["roleable_id=? AND roleable_type='Role' AND role_id=?",current_role_id,original_roleable_id])
      return true
    else
      memberships = self.class.find(:all, :select => "role_id", :conditions => ["roleable_id=? AND roleable_type='Role'",current_role_id])
      if memberships.any? {|membership| belongs_to_itself_through_other?(original_roleable_id,membership.role_id)}
        return true
      end
    end
    return false
  end
end