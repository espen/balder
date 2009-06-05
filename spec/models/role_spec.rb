require File.dirname(__FILE__) + '/../spec_helper'

describe "Role" do

  describe "validations" do
    before(:each) do
      @role = Role.new(:name => "Hunters")
    end
    
    it "should be valid" do
      @role.should be_valid
    end
    
    it "should have a unique name" do
      @role.save
      @role2 = Role.new(:name => "Hunters")
      @role2.should_not be_valid
    end
  end
  
  describe "associations" do
    fixtures :roles, :role_memberships
    
    it "should get subgroups correctly" do
      roles(:company).subroles.size.should == 2
      arr = []
      arr << roles(:publishers)
      arr << roles(:admins)
      roles(:company).subroles.should include(arr.first)
      roles(:company).subroles.should include(arr.last)
      
      roles(:customers).subroles.size.should == 2
      arr = []
      arr << roles(:publishers)
      arr << roles(:advertisers)
      roles(:customers).subroles.should include(arr.first)
      roles(:customers).subroles.should include(arr.last)
    end
    
    it "should get roles correctly" do
      roles(:publishers).roles.size.should == 2
      arr = []
      arr << roles(:customers)
      arr << roles(:company)
      roles(:publishers).roles.should == arr
      
      roles(:admins).roles.size.should == 1
      arr = []
      arr << roles(:company)
      roles(:admins).roles.should == arr
    end
  end
end