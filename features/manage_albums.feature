Feature: Manage Albums
  In order to make a gallery
  As an contributor
  I want to create and manage albums
  
  Scenario: Albums List
  	Given the following album records
		|title|
		|Dizin|
		|Tehran|
		|Delhi|
    When I go to the list of albums
    Then I should see "Dizin"
    And I should see "Tehran"
    And I should see "Delhi"
    And I should have 3 albums
  Scenario: Collection List
	Given I have collections titled "Iran", "India"
	And I have albums titled "Dizin", "Tehran" in collection "Iran"
	And I have albums titled "Delhi" in collection "India"
    When I go to the list of collections
    Then I should see "Iran"
    And I should see "India"
    And I should have 2 collections
    And collection "Iran" should have 2 albums
    And I should have 3 albums
  Scenario: Create Valid Album
	Given the following user records
    	| email              | password |
    	| espen@inspired.no  | megmeg   |
	When I am logged in as "espen@inspired.no" with password "megmeg"
    And I am on the list of albums
    And I have no albums
    When I follow "New Album"
    And I fill in "Title" with "Norway"
    And I fill in "Description" with "The land of the midnight sun"
    And I press "Create"
    And I should see "Album created!"
	Then I follow "All albums"
    And I should see "Norway"
    And I should have 1 album