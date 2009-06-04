class <%= role_membership_model_name %> < ActiveRecord::Base
  #belongs_to :user
  belongs_to :<%= role_model_file_name %>
  belongs_to :roleable, :polymorphic => true
  
  validates_presence_of :roleable_id, :roleable_type, :<%= role_model_file_name %>_id
  validates_uniqueness_of :<%= role_model_file_name %>_id, :scope => [:roleable_id, :roleable_type]
  validates_numericality_of :roleable_id, :<%= role_model_file_name %>_id
  validates_format_of :roleable_type, :with => /^[A-Z]{1}[a-z0-9]+([A-Z]{1}[a-z0-9]+)*$/
  validate :<%= role_model_file_name %>_does_not_belong_to_itself_in_a_loop
  
  protected
  def <%= role_model_file_name %>_does_not_belong_to_itself_in_a_loop
    if roleable_type == "<%= role_model_name %>"
      if <%= role_model_file_name %>_id == roleable_id
        errors.add_to_base("A <%= role_model_file_name %> cannot belong to itself.")
      else
        if belongs_to_itself_through_other?(roleable_id, <%= role_model_file_name %>_id)
          errors.add_to_base("A <%= role_model_file_name %> cannot belong to a <%= role_model_file_name %> which belongs to it.")
        end
      end
    end
  end
  
  def belongs_to_itself_through_other?(original_roleable_id, current_<%= role_model_file_name %>_id)
    if self.class.find(:first, :select => "id", :conditions => ["roleable_id=? AND roleable_type='<%= role_model_name %>' AND <%= role_model_file_name %>_id=?",current_<%= role_model_file_name %>_id,original_roleable_id])
      return true
    else
      memberships = self.class.find(:all, :select => "<%= role_model_file_name %>_id", :conditions => ["roleable_id=? AND roleable_type='<%= role_model_name %>'",current_<%= role_model_file_name %>_id])
      if memberships.any? {|membership| belongs_to_itself_through_other?(original_roleable_id,membership.<%= role_model_file_name %>_id)}
        return true
      end
    end
    return false
  end
end