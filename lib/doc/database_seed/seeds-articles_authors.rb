# -*- coding: utf-8 -*-

puts "="*16, "Authors", "="*16

authors = [
  { first_name: "David", last_name: "Flanagan" },
  { first_name: "Yukihiro", last_name: "Matsumoto" },
  { first_name: "Dave", last_name: "Thomas" },
  { first_name: "Chad", last_name: "Fowler" },
  { first_name: "Andy", last_name: "Hunt" },
  { first_name: "Sam", last_name: "Ruby" },
  { first_name: "David", last_name: "Hansson" }
]

authors.each do |attr|
  puts "#{attr[:last_name]}, #{attr[:first_name]}"
  Author.find_or_create_by(last_name: attr[:last_name], first_name: attr[:first_name])
end

puts "="*16, "Articles", "="*16

books = [
  { title: "The Ruby Programming Language", isbn: "978-0-59651-617-8", pub_date: "February 1, 2008" },
  { title: "Programming Ruby 1.9", isbn: "978-1-93435-608-1", pub_date: "April 15, 2009" },
  { title: "Agile Web Development with Rails", isbn: "978-1-93435-654-8", pub_date: "2011-03-31" },
  { title: "jQuery Pocket Reference", isbn: "978-1-4493-9722-7", pub_date: "December 2010" }
]

books.each do |attr|
  puts attr[:title]
  Article.find_or_create_by(title: attr[:title], isbn: attr[:isbn], pub_date: attr[:pub_date])
end

puts "="*16, "articles_authors", "="*16

Author.find(1).articles << Article.find([1, 4])
Author.find(2).articles << Article.find(1)
Author.find(3).articles << Article.find([2, 3])
Author.find(4).articles << Article.find(2)
Author.find(5).articles << Article.find(2)
Author.find(6).articles << Article.find(3)
Author.find(7).articles << Article.find(3)
