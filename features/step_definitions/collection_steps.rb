Given /^I have collections titled (.+)$/ do |titles|
  titles.split(', ').each do |title|
    Collection.create!(:title => title)
  end
end

Given /^I have no collectins$/ do
  Collection.destroy_all
end

Then /^I should have ([0-9]+) collections?$/ do |count|
  Collection.count.should == count.to_i
end

Then /^collection (.+) should have ([0-9]+) albums?$/ do |collection,count|
  Collection.find(collection).albums.count.should == count.to_i
end