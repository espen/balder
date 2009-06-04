require File.dirname(__FILE__) + '/../spec_helper'

describe <%= class_name %>, "to_hash" do
  before(:each) do
    @permission = <%= class_name %>.new(:permissible_id => 1, :permissible_type => "User", :action => "some_action", :granted => 1)
  end
  
  it "to_hash returns {} if new record" do
    @permission.to_hash.should == {}
  end
  
  it "to_hash returns {action => granted}" do
    @permission.save
    @permission.to_hash.should == {"some_action" => true}
  end

end

describe <%= class_name %>, "validations" do
  before(:each) do
    @permission = <%= class_name %>.new(:permissible_id => 1, :permissible_type => "User", :action => "some_action", :granted => 1)
  end
  
  it "should be valid" do
    @permission.should be_valid
  end

  it "action should be unique to a permissible id and type" do
    @permission.save
    @permission2 = <%= class_name %>.new(:permissible_id => 1, :permissible_type => "User", :action => "some_action", :granted => 0)
    @permission2.should_not be_valid
  end
  
  it "must have a permissible_id" do
    @permission.permissible_id = nil
    @permission.should_not be_valid
  end
  
  it "must have a permissible_type" do
    @permission.permissible_type = nil
    @permission.should_not be_valid
  end
  
  it "must have an action" do
    @permission.action = nil
    @permission.should_not be_valid
    @permission.action = ""
    @permission.should_not be_valid
  end
  
end
