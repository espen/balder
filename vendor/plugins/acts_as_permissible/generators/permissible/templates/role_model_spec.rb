require File.dirname(__FILE__) + '/../spec_helper'

describe "<%= role_model_name %>" do

  describe "validations" do
    before(:each) do
      @<%= role_model_file_name %> = <%= role_model_name %>.new(:name => "Hunters")
    end
    
    it "should be valid" do
      @<%= role_model_file_name %>.should be_valid
    end
    
    it "should have a unique name" do
      @<%= role_model_file_name %>.save
      @<%= role_model_file_name %>2 = <%= role_model_name %>.new(:name => "Hunters")
      @<%= role_model_file_name %>2.should_not be_valid
    end
  end
  
  describe "associations" do
    fixtures :<%= role_model_file_name %>s, :<%= role_membership_model_file_name %>s
    
    it "should get subgroups correctly" do
      <%= role_model_file_name %>s(:company).sub<%= role_model_file_name %>s.size.should == 2
      arr = []
      arr << <%= role_model_file_name %>s(:publishers)
      arr << <%= role_model_file_name %>s(:admins)
      <%= role_model_file_name %>s(:company).sub<%= role_model_file_name %>s.should include(arr.first)
      <%= role_model_file_name %>s(:company).sub<%= role_model_file_name %>s.should include(arr.last)
      
      <%= role_model_file_name %>s(:customers).sub<%= role_model_file_name %>s.size.should == 2
      arr = []
      arr << <%= role_model_file_name %>s(:publishers)
      arr << <%= role_model_file_name %>s(:advertisers)
      <%= role_model_file_name %>s(:customers).sub<%= role_model_file_name %>s.should include(arr.first)
      <%= role_model_file_name %>s(:customers).sub<%= role_model_file_name %>s.should include(arr.last)
    end
    
    it "should get <%= role_model_file_name %>s correctly" do
      <%= role_model_file_name %>s(:publishers).<%= role_model_file_name %>s.size.should == 2
      arr = []
      arr << <%= role_model_file_name %>s(:customers)
      arr << <%= role_model_file_name %>s(:company)
      <%= role_model_file_name %>s(:publishers).<%= role_model_file_name %>s.should == arr
      
      <%= role_model_file_name %>s(:admins).<%= role_model_file_name %>s.size.should == 1
      arr = []
      arr << <%= role_model_file_name %>s(:company)
      <%= role_model_file_name %>s(:admins).<%= role_model_file_name %>s.should == arr
    end
  end
end