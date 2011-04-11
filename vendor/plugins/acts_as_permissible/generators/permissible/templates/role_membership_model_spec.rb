require File.dirname(__FILE__) + '/../spec_helper'

describe "<%= role_membership_model_name %>" do
  
  describe "validations" do
    before(:all) do
      @<%= role_model_file_name.pluralize %> = []
      @<%= role_model_file_name.pluralize %>[0] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>0")
      @<%= role_model_file_name.pluralize %>[1] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>1")
      @<%= role_model_file_name.pluralize %>[2] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>2")
      @<%= role_model_file_name.pluralize %>[3] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>3")
      @<%= role_model_file_name.pluralize %>[4] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>4")
      @<%= role_model_file_name.pluralize %>[5] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>5")
      @<%= role_model_file_name.pluralize %>[6] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>6")
      @<%= role_model_file_name.pluralize %>[7] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>7")
      @<%= role_model_file_name.pluralize %>[8] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>8")
      @<%= role_model_file_name.pluralize %>[9] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>9")
      @<%= role_model_file_name.pluralize %>[10] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>10")
      @<%= role_model_file_name.pluralize %>[11] = <%= role_model_name %>.new(:name => "<%= role_model_file_name %>11")
      @<%= role_model_file_name.pluralize %>.each {|<%= role_model_file_name %>| <%= role_model_file_name %>.save!}
    end
    
    before(:each) do
      @membership = <%= role_membership_model_name %>.new(:roleable_id => @<%= role_model_file_name.pluralize %>[0].id, :roleable_type => "<%= role_model_name %>", :<%= role_model_file_name %>_id => @<%= role_model_file_name.pluralize %>[1].id)
    end
    
    it "should be valid" do
      @membership.should be_valid
    end
    
    # roleable_id
    it "should have a roleable_id" do
      @membership.roleable_id = nil
      @membership.should_not be_valid
    end
    
    it "roleable_id should be an integer" do
      @membership.roleable_id = "asd"
      @membership.should_not be_valid
    end
    
    # roleable_type
    it "should have a roleable_type" do
      @membership.roleable_type = nil
      @membership.should_not be_valid
    end
    
    it "roleable_type should be a string" do
      @membership.roleable_type = 123
      @membership.should_not be_valid
    end
    
    it "roleable_type should have a class name format" do
      @membership.roleable_type = "asd"
      @membership.should_not be_valid
      @membership.roleable_type = "User"
      @membership.should be_valid
      @membership.roleable_type = "Some95WierdClassN4m3"
      @membership.should be_valid
    end
    
    # <%= role_model_file_name %>_id
    it "should have a <%= role_model_file_name %>_id" do
      @membership.<%= role_model_file_name %>_id = nil
      @membership.should_not be_valid
    end
    
    it "<%= role_model_file_name %>_id should be an integer" do
      @membership.<%= role_model_file_name %>_id = "asd"
      @membership.should_not be_valid
    end
    
    it "should not allow a <%= role_model_file_name %> to belong to itself" do
      @membership.<%= role_model_file_name %>_id = @<%= role_model_file_name.pluralize %>[0].id
      @membership.should_not be_valid
    end
    
    # <%= role_model_file_name.pluralize %> cannot belong to each other in a loop
    it "should not a allow a <%= role_model_file_name %> to belong to a <%= role_model_file_name %> which belongs to it in a loop" do
      @<%= role_model_file_name.pluralize %>[0].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[1]
      @<%= role_model_file_name.pluralize %>[1].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[2]
      @<%= role_model_file_name.pluralize %>[2].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[3]
      @<%= role_model_file_name.pluralize %>[2].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[4]
      @<%= role_model_file_name.pluralize %>[2].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[5]
      @<%= role_model_file_name.pluralize %>[3].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[6]
      @<%= role_model_file_name.pluralize %>[1].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[7]
      @<%= role_model_file_name.pluralize %>[3].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[8]
      @<%= role_model_file_name.pluralize %>[4].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[9]
      @<%= role_model_file_name.pluralize %>[4].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[10]
      @<%= role_model_file_name.pluralize %>[5].<%= role_model_file_name.pluralize %> << @<%= role_model_file_name.pluralize %>[11]
      @membership3 = <%= role_membership_model_name %>.new(:roleable_id => @<%= role_model_file_name.pluralize %>[11].id, :roleable_type => "<%= role_model_name %>", :<%= role_model_file_name %>_id => @<%= role_model_file_name.pluralize %>[0].id)
      @membership3.should_not be_valid
      @membership3.errors.full_messages.should include("A <%= role_model_file_name %> cannot belong to a <%= role_model_file_name %> which belongs to it.")
    end
    
    after(:all) do
      @<%= role_model_file_name.pluralize %>.each {|<%= role_model_file_name %>| <%= role_model_file_name %>.destroy}
    end
  end
end