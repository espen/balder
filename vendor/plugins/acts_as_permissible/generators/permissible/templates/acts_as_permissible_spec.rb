require File.dirname(__FILE__) + '/../spec_helper'

class <%= class_name %> < ActiveRecord::Base
  acts_as_permissible
end

describe "acts_as_permissible" do
  fixtures :<%= table_name %>
  
  before(:each) do
    @perm = <%= table_name %>(:perm)
  end
  
  describe "class methods" do
    it "should find_permissions_for(obj) correctly" do
      <%= class_name %>.find_permissions_for(@perm).size.should == 2
      <%= class_name %>.find_permissions_for(@perm).first.action.should == "view_something"
      <%= class_name %>.find_permissions_for(@perm).last.action.should == "delete_something"
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
      @perm2 = <%= table_name %>(:perm2)
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
      @perm.<%= table_name %> << <%= class_name %>.new(:action => "add_something", :granted => true)
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
  <% unless options[:skip_roles] %>
  describe "<%= role_model_file_name.pluralize %>_list" do
    before(:each) do
      @perm.<%= role_model_file_name.pluralize %>_list.should == []
      @mutables = <%= role_model_name %>.new(:name => "mutables")
      @mutables.save!
      @wierdos = <%= role_model_name %>.new(:name => "wierdos")
      @wierdos.save!
      @mutables.<%= role_model_file_name.pluralize %> << @wierdos
    end

    after(:each) do
      @mutables.destroy
      @wierdos.destroy
      @perm.<%= role_model_file_name.pluralize %>.reset
      @perm.<%= role_model_file_name.pluralize %>_list.should == []
    end

    it "should return the correct list" do
      @perm.<%= role_model_file_name.pluralize %> << @wierdos
      @perm.<%= role_model_file_name.pluralize %>_list.size.should == 1
      @perm.<%= role_model_file_name.pluralize %>_list.should include("wierdos")
    end

    it "should return the correct list including parent <%= role_model_file_name.pluralize %> of <%= role_model_file_name.pluralize %> recursively." do
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.<%= role_model_file_name.pluralize %>_list.size.should == 2
      @perm.<%= role_model_file_name.pluralize %>_list.should include("mutables")
      @perm.<%= role_model_file_name.pluralize %>_list.should include("wierdos")
    end
  end
  
  describe "in_<%= role_model_file_name %>?" do
    before(:each) do
      @mutables = <%= role_model_name %>.new(:name => "mutables")
      @mutables.save!
      @immutables = <%= role_model_name %>.new(:name => "immutables")
      @immutables.save!
    end
    
    after(:each) do
      @mutables.destroy
      @immutables.destroy
      @perm.<%= role_model_file_name.pluralize %>.reset
    end
    
    it "should return true if member of one" do
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.in_<%= role_model_file_name %>?("mutables").should == true
    end
    
    it "should return false if not a member" do
      @perm.in_<%= role_model_file_name %>?("mutables").should == false
    end
    
    it "should return true if member of all" do
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.<%= role_model_file_name.pluralize %> << @immutables
      @perm.in_<%= role_model_file_name %>?("mutables","immutables").should == true
    end
    
    it "should return false if member of some" do
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.in_<%= role_model_file_name %>?("mutables","immutables").should == false
    end
  end
  
  describe "in_any_<%= role_model_file_name %>?" do
    before(:each) do
      @mutables = <%= role_model_name %>.new(:name => "mutables")
      @mutables.save!
      @immutables = <%= role_model_name %>.new(:name => "immutables")
      @immutables.save!
    end
    
    it "should return true if member of one" do
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.in_any_<%= role_model_file_name %>?("mutables","immutables").should == true
    end
    
    it "should return false if not a member" do
      @perm.in_any_<%= role_model_file_name %>?("mutables","immutables").should == false
    end
    
    it "should return true if member of all" do
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.<%= role_model_file_name.pluralize %> << @immutables
      @perm.in_any_<%= role_model_file_name %>?("mutables","immutables").should == true
    end
  end
  
  describe "full_permissions_hash" do
    before(:each) do
      @mutables = <%= role_model_name %>.new(:name => "mutables")
      @mutables.save!
      @mutable_permission = <%= class_name %>.new(:permissible_id => @mutables.id, :permissible_type => @mutables.class.to_s, :action => "view_something", :granted => false)
      @mutable_permission.save!
      @immutables = <%= role_model_name %>.new(:name => "immutables")
      @immutables.save!
      @immutable_permission = <%= class_name %>.new(:permissible_id => @immutables.id, :permissible_type => @immutables.class.to_s, :action => "download_something", :granted => true)
      @immutable_permission.save!
    end
    
    it "should return the correct hash if object doesn't belong to <%= role_model_file_name.pluralize %>" do
      @perm.<%= role_model_file_name.pluralize %>.should == []
      @perm.full_permissions_hash.should == {:view_something=>true, :delete_something=>false}
    end
    
    it "should return the correct hash if object belongs to one <%= role_model_file_name %>" do
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.full_permissions_hash.should == {:view_something=>false, :delete_something=>false}
    end
    
    it "should return the correct hash if object belongs to one <%= role_model_file_name %> which belongs to another <%= role_model_file_name %>" do
      @mutables.<%= role_model_file_name.pluralize %> << @immutables
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.full_permissions_hash.should == {:view_something=>false, :delete_something=>false, :download_something=>true}
    end
    
    it "should return the correct hash if object belongs to 2 <%= role_model_file_name.pluralize %>" do
      @perm.<%= role_model_file_name.pluralize %> << @immutables
      @perm.<%= role_model_file_name.pluralize %> << @mutables
      @perm.full_permissions_hash.should == {:view_something=>false, :delete_something=>false, :download_something=>true}
    end
    
    after(:each) do
      @mutables.destroy
      @immutables.destroy
      @perm.<%= role_model_file_name.pluralize %>.reset
    end
  end
  <% end %>
end
