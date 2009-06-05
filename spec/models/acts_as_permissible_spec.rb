require File.dirname(__FILE__) + '/../spec_helper'

class Permission < ActiveRecord::Base
  acts_as_permissible
end

describe "acts_as_permissible" do
  fixtures :permissions
  
  before(:each) do
    @perm = permissions(:perm)
  end
  
  describe "class methods" do
    it "should find_permissions_for(obj) correctly" do
      Permission.find_permissions_for(@perm).size.should == 2
      Permission.find_permissions_for(@perm).first.action.should == "view_something"
      Permission.find_permissions_for(@perm).last.action.should == "delete_something"
    end
  end
  
  describe "permissions_hash" do
    it "should return the correct permissions_hash" do
      @perm.permissions_hash.should == {:view_something => true, :delete_something => false}
    end
  end

  describe "has_permission?" do
    it "should return true if permission found" do
      @perm.has_permission?("view_something").should == true
    end

    it "should return false if permission not found" do
      @perm.has_permission?("create_something").should == false
    end

    it "should return false if permission found and is denied" do
      @perm.has_permission?("delete_something").should == false
    end
  end

  describe "merge_permissions!" do
    before(:each) do
      @perm2 = permissions(:perm2)
      @merged_permissions = @perm.merge_permissions!(@perm2.permissions_hash)
      # {:update_something=>true, :view_something=>true, :delete_something=>false, :create_something=>false}
    end
    
    it "should include all keys from both hashes" do
      @merged_permissions.keys.should == 
      (@perm.permissions_hash.keys + @perm2.permissions_hash.keys).uniq
    end
    
    it "should override identical keys with false value" do
      @merged_permissions[:delete_something].should == false
    end
  end
  
  describe "reload_permissions!" do
    before(:each) do
      @original_hash = @perm.permissions_hash
      @perm.permissions << Permission.new(:action => "add_something", :granted => true)
    end
    
    it "should catch-up with database changes" do
      @perm.permissions_hash.should == @original_hash
      reloaded_hash = @perm.reload_permissions!
      reloaded_hash.should_not == @original_hash
    end
    
    it "should get the changes correctly" do
      reloaded_hash = @perm.reload_permissions!
      reloaded_hash.keys.should include(:add_something)
    end
  end
  
  describe "roles_list" do
    before(:each) do
      @perm.roles_list.should == []
      @mutables = Role.new(:name => "mutables")
      @mutables.save!
      @wierdos = Role.new(:name => "wierdos")
      @wierdos.save!
      @mutables.roles << @wierdos
    end

    after(:each) do
      @mutables.destroy
      @wierdos.destroy
      @perm.roles.reset
      @perm.roles_list.should == []
    end

    it "should return the correct list" do
      @perm.roles << @wierdos
      @perm.roles_list.size.should == 1
      @perm.roles_list.should include("wierdos")
    end

    it "should return the correct list including parent roles of roles recursively." do
      @perm.roles << @mutables
      @perm.roles_list.size.should == 2
      @perm.roles_list.should include("mutables")
      @perm.roles_list.should include("wierdos")
    end
  end
  
  describe "in_role?" do
    before(:each) do
      @mutables = Role.new(:name => "mutables")
      @mutables.save!
      @immutables = Role.new(:name => "immutables")
      @immutables.save!
    end
    
    after(:each) do
      @mutables.destroy
      @immutables.destroy
      @perm.roles.reset
    end
    
    it "should return true if member of one" do
      @perm.roles << @mutables
      @perm.in_role?("mutables").should == true
    end
    
    it "should return false if not a member" do
      @perm.in_role?("mutables").should == false
    end
    
    it "should return true if member of all" do
      @perm.roles << @mutables
      @perm.roles << @immutables
      @perm.in_role?("mutables","immutables").should == true
    end
    
    it "should return false if member of some" do
      @perm.roles << @mutables
      @perm.in_role?("mutables","immutables").should == false
    end
  end
  
  describe "in_any_role?" do
    before(:each) do
      @mutables = Role.new(:name => "mutables")
      @mutables.save!
      @immutables = Role.new(:name => "immutables")
      @immutables.save!
    end
    
    it "should return true if member of one" do
      @perm.roles << @mutables
      @perm.in_any_role?("mutables","immutables").should == true
    end
    
    it "should return false if not a member" do
      @perm.in_any_role?("mutables","immutables").should == false
    end
    
    it "should return true if member of all" do
      @perm.roles << @mutables
      @perm.roles << @immutables
      @perm.in_any_role?("mutables","immutables").should == true
    end
  end
  
  describe "full_permissions_hash" do
    before(:each) do
      @mutables = Role.new(:name => "mutables")
      @mutables.save!
      @mutable_permission = Permission.new(:permissible_id => @mutables.id, :permissible_type => @mutables.class.to_s, :action => "view_something", :granted => false)
      @mutable_permission.save!
      @immutables = Role.new(:name => "immutables")
      @immutables.save!
      @immutable_permission = Permission.new(:permissible_id => @immutables.id, :permissible_type => @immutables.class.to_s, :action => "download_something", :granted => true)
      @immutable_permission.save!
    end
    
    it "should return the correct hash if object doesn't belong to roles" do
      @perm.roles.should == []
      @perm.full_permissions_hash.should == {:view_something=>true, :delete_something=>false}
    end
    
    it "should return the correct hash if object belongs to one role" do
      @perm.roles << @mutables
      @perm.full_permissions_hash.should == {:view_something=>false, :delete_something=>false}
    end
    
    it "should return the correct hash if object belongs to one role which belongs to another role" do
      @mutables.roles << @immutables
      @perm.roles << @mutables
      @perm.full_permissions_hash.should == {:view_something=>false, :delete_something=>false, :download_something=>true}
    end
    
    it "should return the correct hash if object belongs to 2 roles" do
      @perm.roles << @immutables
      @perm.roles << @mutables
      @perm.full_permissions_hash.should == {:view_something=>false, :delete_something=>false, :download_something=>true}
    end
    
    after(:each) do
      @mutables.destroy
      @immutables.destroy
      @perm.roles.reset
    end
  end
  
end
