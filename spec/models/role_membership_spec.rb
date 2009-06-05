require File.dirname(__FILE__) + '/../spec_helper'

describe "RoleMembership" do
  
  describe "validations" do
    before(:all) do
      @roles = []
      @roles[0] = Role.new(:name => "role0")
      @roles[1] = Role.new(:name => "role1")
      @roles[2] = Role.new(:name => "role2")
      @roles[3] = Role.new(:name => "role3")
      @roles[4] = Role.new(:name => "role4")
      @roles[5] = Role.new(:name => "role5")
      @roles[6] = Role.new(:name => "role6")
      @roles[7] = Role.new(:name => "role7")
      @roles[8] = Role.new(:name => "role8")
      @roles[9] = Role.new(:name => "role9")
      @roles[10] = Role.new(:name => "role10")
      @roles[11] = Role.new(:name => "role11")
      @roles.each {|role| role.save!}
    end
    
    before(:each) do
      @membership = RoleMembership.new(:roleable_id => @roles[0].id, :roleable_type => "Role", :role_id => @roles[1].id)
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
    
    # role_id
    it "should have a role_id" do
      @membership.role_id = nil
      @membership.should_not be_valid
    end
    
    it "role_id should be an integer" do
      @membership.role_id = "asd"
      @membership.should_not be_valid
    end
    
    it "should not allow a role to belong to itself" do
      @membership.role_id = @roles[0].id
      @membership.should_not be_valid
    end
    
    # roles cannot belong to each other in a loop
    it "should not a allow a role to belong to a role which belongs to it in a loop" do
      @roles[0].roles << @roles[1]
      @roles[1].roles << @roles[2]
      @roles[2].roles << @roles[3]
      @roles[2].roles << @roles[4]
      @roles[2].roles << @roles[5]
      @roles[3].roles << @roles[6]
      @roles[1].roles << @roles[7]
      @roles[3].roles << @roles[8]
      @roles[4].roles << @roles[9]
      @roles[4].roles << @roles[10]
      @roles[5].roles << @roles[11]
      @membership3 = RoleMembership.new(:roleable_id => @roles[11].id, :roleable_type => "Role", :role_id => @roles[0].id)
      @membership3.should_not be_valid
      @membership3.errors.full_messages.should include("A role cannot belong to a role which belongs to it.")
    end
    
    after(:all) do
      @roles.each {|role| role.destroy}
    end
  end
end