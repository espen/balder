Given /i am logged in as a user in the (.*) role/i do |role|
  #@user = Factory.create(:user, :name => "Espen Antonsen",  
  #  :email => "espen@inspired.no",  
  #  :password => "megmeg")
  #@role = Factory.create(:role, :rolename => role)
  #@user.roles << @role
  visits "/login"  
  fills_in("email", :with => "espen@inspired.no")
  fills_in("password", :with => "megmeg")
  clicks_button("Log in")
end


Given /^I have albums titled (.+) in collection (.+)$/ do |titles,collection|
  titles.split(', ').each do |title|
    CollectionAlbum.create( :collection => Collection.find_by_title(collection), :album => Album.create!(:title => title) )
  end
end

Given /^I have no albums$/ do
  Album.destroy_all
end

Then /^I should have ([0-9]+) albums?$/ do |count|
  Album.count.should == count.to_i
end