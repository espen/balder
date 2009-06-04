Given /^I am logged in as "([^\"]*)" with password "([^\"]*)"$/ do |email, password|
  unless email.blank?
    visit login_url
    fill_in "Email", :with => email
    fill_in "Password", :with => password
    click_button "Login"
  end
end

When /^I visit profile for "([^\"]*)"$/ do |email|
  user = User.find_by_email!(email)
  visit user_url(user)
end