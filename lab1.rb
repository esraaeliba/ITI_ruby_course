require 'json'

class Inventory
  def initialize(file_name)
    @file_name = file_name
    @books = load_books
  end

  def load_books
    if File.exist?(@file_name)
      JSON.parse(File.read(@file_name))
    else
      []
    end
  end

  def save_books
    File.open(@file_name, 'w') { |file| file.puts JSON.generate(@books) }
  end

  def list_books
    @books.each do |book|
      puts "Title: #{book['title']}, Author: #{book['author']}, ISBN: #{book['isbn']}, Count: #{book['count']}"
    end
  end

  def add_book(title = nil, author = nil, isbn = nil)
    if title.nil? || author.nil? || isbn.nil? || title.strip.empty? || author.strip.empty? || isbn.strip.empty?
      puts "Error: Please provide a non-empty title, author, and ISBN."
      return
    end

    existing_book = @books.find { |book| book['isbn'] == isbn }

    if existing_book
      existing_book['title'] = title
      existing_book['author'] = author
      existing_book['count'] += 1
      puts "Book with ISBN #{isbn} already exists. Title and author updated. Book count incremented."
    else
      @books << { 'title' => title, 'author' => author, 'isbn' => isbn, 'count' => 1 }
      puts "Book added successfully."
    end

    save_books
  end

  def remove_book(isbn)
    @books.reject! { |book| book['isbn'] == isbn }
    puts "Book with ISBN #{isbn} removed successfully."
    save_books
  end

  def search_books(title = nil, author = nil, isbn = nil)
    results = @books

    results = results.select { |book| book['title'] == title } if title
    results = results.select { |book| book['author'] == author } if author
    results = results.select { |book| book['isbn'] == isbn } if isbn

    results.each do |book|
      puts "Title: #{book['title']}, Author: #{book['author']}, ISBN: #{book['isbn']}"
    end
  end

  def sort_books(title: false, author: false, isbn: false)
    sorted_books = @books

    if title
      sorted_books = sorted_books.sort_by { |book| book['title'] }
    elsif author
      sorted_books = sorted_books.sort_by { |book| book['author'] }
    elsif isbn
      sorted_books = sorted_books.sort_by { |book| book['isbn'].to_i }
    end

    sorted_books.each do |book|
      puts "Title: #{book['title']}, Author: #{book['author']}, ISBN: #{book['isbn']}"
    end
  end

  def print_menu
    puts "\nMenu:"
    puts "1. List Books"
    puts "2. Add Book"
    puts "3. Remove Book"
    puts "4. Search Book"
    puts "5. Sort Books"
    puts "6. Exit"
  end
end

inventory = Inventory.new('books.json')

loop do
  inventory.print_menu
  print "Enter your choice: "
  choice = gets.chomp.to_i

  case choice
  when 1
    inventory.list_books
  when 2
    print "Enter title: "
    title = gets.chomp
    print "Enter author: "
    author = gets.chomp
    print "Enter ISBN: "
    isbn = gets.chomp
    inventory.add_book(title, author, isbn)
  when 3
    print "Enter ISBN of the book to remove: "
    isbn = gets.chomp
    inventory.remove_book(isbn)
  when 4
    print "Enter title (leave blank if not searching by title): "
    title = gets.chomp
    print "Enter author (leave blank if not searching by author): "
    author = gets.chomp
    print "Enter ISBN (leave blank if not searching by ISBN): "
    isbn = gets.chomp
    inventory.search_books(title.empty? ? nil : title, author.empty? ? nil : author, isbn.empty? ? nil : isbn)
  when 5
    print "Sort by title? (true/false): "
    sort_title = gets.chomp.downcase == 'true'
    print "Sort by author? (true/false): "
    sort_author = gets.chomp.downcase == 'true'
    print "Sort by ISBN? (true/false): "
    sort_isbn = gets.chomp.downcase == 'true'
    inventory.sort_books(title: sort_title, author: sort_author, isbn: sort_isbn)
  when 6
    puts "Exiting program."
    break
  else
    puts "Invalid choice. Please select a valid option."
  end
end
