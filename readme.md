<h1> Google Books API and Reading List </h1>

A small command-line program designed to query google books API. After querying, books are able to be added to a reading list and viewed. The project was created in ruby version 2.5.1p57, and requires ruby version >= 2.4.0. It utilizes sqlite3 as a simple database, ttyprompt for some easy-to-manage UI improvements, and rest client for API queries.  

<h1> Goals for this project </h1>

* Type in a query and display a list of 5 books matching that query.
* Each item in the list should include the book's author, title, and publishing company.
* A user should be able to select a book from the five displayed to save to a “Reading List”
* View a “Reading List” with all the books the user has selected from their queries -- this is a local reading list and not tied to Google Books account features.

<h1> To run </h1>

1. Navigate to 8thLightStevenKunzel in the terminal.
2. Ensure ruby version 2.4.0 or higher is installed.
2. Run bundle install in the console to install relevant gems.
3. Open to the .env file and place your google books api key after the = for booksApiKey
4. Run ruby readingList.rb in the console. 

<h1> Approach </h1>

My approach was to initialize our class with a hash for the reading list, initialize the prompt gem, grab our api key from the .env file, and run a program function. I also used an sqlite3 database for some light information retainment. A database will be created if none exists, and it will be opened if it already does exist. A table is created called bookList if not already created, with some columns for title, author, and publisher. We start the program by pulling from this DB and putting everything into a reference hash called list.

Passing to the program function, we are given a selection to view our list, look up new books, or exit.

Upon viewing, we run viewlist. This either returns an empty list message or displays our hash's keys with some formatting. It then returns to program, and reruns it.

Selecting lookup runs the search function. The search function displays a list of filter options and a back button. Back will return us to program, and rerun program. A variable term is used, because there is a difference in the query parameter between subject and other search's (all others contain "in" in the search param).

Upon creating a proper searchField, it moves to the searchInput function to retrieve the user input. Here we have a small error catch if the user just hits enter without typing, it will just do a blank search. This could be altered to prompt the user that they must enter information.

It returns the search term to the search function, moving to the query function.

The query function interpolates the passed searchField and searchTerm into a URL adding a limit of 5 to the max results, and utilizing google API's "projection=lite" param to make the records smaller in size, including less irrelevant information. It runs a query to the API, parsing the data into JSON. We check if the length is greater than 3 because anything less indicates no results. If there are results, we will display to the user the results found, including the title, author, and publisher. If the user selects back, the search is run again, otherwise, they can select an item.

Selecting an item sends the selection to the listAndDbInsert function. This formats the selection to check if it is already present in the @list hash. If it isn't, it inserts and executes a database insertion.

<h1> Resources </h1>

Ruby installation documentation.   
* https://www.ruby-lang.org/en/documentation/installation/

The google books API documentation is here.
* https://developers.google.com/books/docs/overview

Accessing the google books API was done through the aid of the rest-client gem. You can see this link for documentation on rest-client. Ruby version >= 2.0.0 is required.
* https://github.com/rest-client/rest-client

I also installed a helpful integration called tty-prompt. This allows for some easy-to-manage UI improvements. See documentation here. Ruby version >= 2.0.0 is required.
* https://github.com/piotrmurach/tty-prompt

Sqlite3 documentation, specific to ruby. Some more references are linked here as well. Ruby version >= 1.8.7 is required.
* https://rubydoc.info/gems/sqlite3/1.3.8/frames

dotenv is used to allow for an easier key setup then previously explored. This documentation refers to rails, however the gem can be used without requiring a rails setup. No Ruby version requirement.
* https://github.com/bkeepers/dotenv

Byebug is included. This would be removed on a production build, but it is included if you'd like to use it. Simply place debugger on a line. See documentation here. Ruby version >= 2.4.0 is required.
* https://github.com/deivid-rodriguez/byebug

<h1> Future considerations </h1>

1. Add tests. I decided against tests for this project due to time constraints, but RSPEC could be utilized for a spec-based testing suite.
2. Make the list more readable, perhaps a nice-looking table that organizes everything.
3. Ability to delete from the reading list, or check off completed books to move to a finished list, etc.
4. Filter further, by title AND author, by year, etc.
5. User login integration.
6. Next button for queries to allow choices beyond just 5.
7. Better key security.

<h1> Feedback Changes </h1>
<h2> Feedback 6/24/21 from Hugh Sato </h2>

1. Debugger gem only works for Ruby < 2.0, and given that the Ruby version was not defined in the readme, I had to add byebug on my own to figure out how to successfully bundle install. 
   Can we update the gemfile to meet build needs? What else could we do to make sure setup is seamless?
2. Exploring using dotenv instead of relying on exporting an API key at the system level would be preferable. I was not able to get it working by exporting in zsh.
3. Can we add more documentation on the ruby version needed to run this program?
4. Could we add a few tests around your methods, time permitting?

<h2> Applied changes to 6/24/21 </h2>

1. The gem was incorrectly labeled 'debugger' in the gemfile. This should have been 'byebug'. I believe the require statement was working on my end because I must have byebug globally installed.
   Fixing this should resolve point one.  
2. dotenv gem has been installed, negating the need to create an environment variable in terminal.  I decided to push the .env file and remove my personal key, to make the setup easier for the end user. 
We might instead consider gitignoring this file and ensuring our other programmers know to add in a .env file, so that no accidental key uploads can occur.
3. The most recent version of ruby required is from the byebug gem, requiring ruby 2.4.0 or higher. 
   While we should be able to dynamically allow for the gem to install the most recent version of byebug depending on the user's ruby version (getting us down to 2.0 or higher), I prefer to have a higher requirement of the ruby version for stability and security.
4. 