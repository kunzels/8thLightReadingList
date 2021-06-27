require 'byebug'
require 'tty-prompt'
require 'rest-client'
require 'json'
require 'sqlite3'
require 'dotenv'
Dotenv.load

class ReadingList
  
    def initialize()
        # Initialize our list, prompt, and key. Populates list from DB insertions. Runs our primary program function.
        @list = {}
        @prompt = TTY::Prompt.new
        @key = ENV.fetch('booksApiKey')
       
        @db = SQLite3::Database.open 'readingList.db'
        rows = @db.execute <<-SQL
            create table if not exists bookList (
            title text,
            author text,
            publisher text);
        SQL
        @db.execute( "select * from bookList") do |item|
            @list[item] = true
        end
        program()
    end

    def program()
        # Main Menu
        response = @prompt.select("\nWhat would you like to do?\n") do |menu|
            menu.choice "View My Reading List", "view"
            menu.choice "Lookup New Books", "lookup"
            menu.choice "Exit", "exit"
        end   
        # Response dictates which function to hit. Program continues running unless exit is selected.
        case response
            when "view"
                viewList() 
                program()
            when "lookup"
                search()
                program()
            when "exit"
                print "\n\n Have a great day! \n\n"
        end
    end

    def viewList()
        if @list.length == 0
            print "\nYou have no current books in your reading list \n"
        else # Shovelling (<<) is prefered to += here, alters the original string rather than creating new ones. Our key is an array. 
            @list.each do |k, v|
                puts "\n" << "Title: " << k[0] << "\nAuthor/s: " << k[1].to_s << "\nPublisher: " << k[2].to_s << "\n"
            end
        end
    end

    def search() # We may want to allow for even more focused query filtering (title and author and year etc).
        searchField = @prompt.select("\nHow do you want to search?\n")  do |menu|
            menu.choice "By Title", "intitle"
            menu.choice "By Author", "inauthor"
            menu.choice "By Publisher", "inpublisher"
            menu.choice "By Subject", "subject"
            menu.choice "Back", "back"
            # These are also able to be searched from the API.
            # menu.choice "By isbn", "isbn"
            # menu.choice "By lccn", "lccn"
            # menu.choice "By oclc", "oclc"
        end
        if searchField != "back"
            # Google Books API uses keyword params. These next two lines just remove the "in" from the first three searchField options for clarity to the user, 
            # since subject does not contain in. Keep this in mind if we add isbn, lccn, or oclc. 
            term = nil
            searchField == "subject" ? term = searchField : term = searchField[2..-1]
            searchTerm = searchInput(term)
            query(searchField, searchTerm)
        end
    end

    def searchInput(term)
        # User inputs a title, author, publisher, subject. gsub strips spaces and adds '+' for the query params. Sends to the query function.
        searchTerm = @prompt.ask("\nPlease enter the #{term}:\n")
        searchTerm == nil ? searchTerm = "" : searchTerm.gsub(/\s+/, "+")
        return searchTerm
    end
    
    def query(searchField, searchTerm)
        # Construct URL, send a get request to the api, parse. maxResults added. See api documentation for url param clarity.  
        url = "https://www.googleapis.com/books/v1/volumes?q=#{searchField}:#{searchTerm}&maxResults=5&projection=lite&:keyes&key=#{@key}"
        response = JSON.parse(RestClient.get(url))
        # If there arent results, else display the received options.
        if response.length < 3
            puts "\nThere were no selections found\n"
        else
            # display results to choose from
            selection = @prompt.select("\nSelect an item to add to your reading list\n")  do |menu|
                response["items"].each do |book|
                    bookInfo = book["volumeInfo"]
                    title = bookInfo["title"]
                    authors = bookInfo["authors"]
                    publisher = bookInfo["publisher"]
                    menu.choice "Title: #{title}, Author/s:#{authors.to_s}, Publisher: #{publisher}", [title, authors, publisher]
                end
                menu.choice "Back", "back"
            end
            # Chooses where to send the selection
            if selection != "back"
                listAndDbInsert(selection)
            else 
                search()
            end
        end
    end

    def listAndDbInsert(selection)
        # Formats for insertion and inclusion check
        selection[1] == nil ? selection[1] = "No listed author" : selection[1] = selection[1].join(", ")
        selection[2] = "No listed publisher" if selection[2] == nil 
        # If unadded, adds to list and db
        if !@list[selection]
            @list[selection] = true
            @db.execute "INSERT INTO bookList (title, author, publisher) VALUES (?, ?, ?)", selection[0], selection[1], selection[2]
            print "\n#{selection} has been added to your reading list\n"
        else 
            print "\nThis is already in your reading list\n"
            search()
        end
    end
end

list = ReadingList.new()
