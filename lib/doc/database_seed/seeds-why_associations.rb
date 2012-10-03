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
  puts attr[:last_name]
  Author.find_or_create_by_last_name_and_first_name(attr)

  # jeśli atrybutu :first_name nie ma na liście attr_accessible
  # ale w taki sposób nie zapiszemy dwóch kowalskich, np.
  #  Kowalski, Jan
  #  Kowalski, Zenek
  #
  # Author.find_or_initialize_by_last_name(attr[:last_name]).tap do |t|
  #   t.first_name = attr[:first_name]
  #   t.save!
  # end
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
  Article.find_or_create_by_title_and_isbn_and_pub_date(attr)

  # jw.
  # i tutaj też będziemy mieli problem z różnymi wydaniami
  # tej samej książki
  #
  # Article.find_or_initialize_by_title(attr[:title]).tap do |t|
  #   t.isbn = attr[:isbn]
  #   t.pub_date = attr[:pub_date]
  #   t.save!
  # end
end

puts "="*16, "Bibinfos", "="*16

bibinfos = [
  { author_id: 1, article_id: 1 },
  { author_id: 1, article_id: 4 },
  { author_id: 2, article_id: 1 },
  { author_id: 3, article_id: 2 },
  { author_id: 3, article_id: 3 },
  { author_id: 4, article_id: 2 },
  { author_id: 5, article_id: 2 },
  { author_id: 6, article_id: 3 },
  { author_id: 7, article_id: 3 }
]

bibinfos.each do |attr|
  # atrybutów :author_id i :article_id nie ma na liście attr_accessible
  # ważna jest kolejność argumentów
  Bibinfo.find_or_create_by_author_id_and_article_id(attr[:author_id], attr[:article_id])
end
