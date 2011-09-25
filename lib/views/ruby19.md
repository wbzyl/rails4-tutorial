#### {% title "Ruby 1.9 w pigułce" %}

<blockquote>
 {%= image_tag "/images/in_a_nutshell.jpg", :alt => "[In a Nutshell]" %}
 <p>This may not be very scientific, but perhaps this is why Ruby is such a wonderful language.</p>
 <p class="author">[<a href="http://pjkh.com/articles/2009/11/13/ruby-in-a-nutshell">phil•ip
  hall•strom</a>]</p>
</blockquote>

Na sigmie zainstalowany jest ruby-1.9.2-p290.

Podręczniki do języka Ruby:

* [Why's (Poignant) Guide to Ruby](http://www.rubyinside.com/media/poignant-guide.pdf)
* [Mr. Neighborly's Humble Little
  Ruby Book](http://www.humblelittlerubybook.com/book/html/index.html)
  \([pdf](http://www.humblelittlerubybook.com/book/hlrb.pdf)\)
* [Learn Ruby The Hard Way](http://ruby.learncodethehardway.org/)
* [Hyperpolyglot](http://hyperpolyglot.org/scripting) – nie tylko Ruby!

Strony, gdzie od czasu do czasu warto zajrzeć:

* [RVM](http://rvm.beginrescueend.com/) – Ruby Version Manager
* [Ruby Programming Language](http://rubylang.info/) –
  community driven web site, dedicated to helping
  both new and experienced Ruby developers
* [stackoverflow](http://stackoverflow.com/questions/tagged/ruby) –
  questions tagged with **ruby**
* [Rubyflow](http://rubyflow.com)


## Hasze

    :::ruby
    h = {1 => 2,3 => 4,5 => 6}
    h.keys
    h.values
    h[7] = 8
    h #  {5=>6, 1=>2, 7=>8, 3=>4}
    h.to_a

## Tablice

    :::ruby
    a = [1,2,3,4,5,6]
    a.object_id
    a.to_a.object_id
    str = "hello\nworld"
    str.to_a
    4.to_a # warning: default 'to_a' will be obsolete
    *c = 1, 2, 3, 4

## Symbole

    :::ruby
    Object.new.methods.sort # 1.9 lista symboli, 1.8 – napisów
    Object.new.methods.grep(/methods/)
    words= %w{ witaj świecie }
    words.map { |w| w.upcase }
    words.map(&:upcase)  # 1.9

## Enumerators 1.8

    :::ruby
    a = [2,4,6,8]
    a.each {|n| p n + 10}
    a.each_with_index {|n,i| p "#{i} -> #{n}" }
    a.map {|n| n + 10}
    a.find {|n| n > 4}
    a.inject {|acc,n| acc + n}
    a.class
    a.class.ancestors


## Moduł Enumerable

    :::ruby
    pr = [1.3, 2.5, 4.1, 1.8]
    pr.max
    pr.min
    pr.map! {|n| n.to_s}
    a = [*1..10]
    a.group_by {|x| x % 2}  # 1.9, yields a hash
    class Person
      attr_reader :age
      def initialize(age)
        @age = age
      end
      def <=>(other)
        self.age <=> other.age
      end
    end
    a = Person.new(20)
    b = Person.new(30)
    c = Person.new(30)
    d = Person.new(25)
    [a,b,c,d].sort.group_by {|person| person.age}  # 1.9
    [a,b,c,d].sort.group_by(&:age)                 # 1.9
    a = [*1..10]
    a.each_cons(3) {|cons| p cons }
    a.each_slice(3) {|cons| p cons }
    a.each_cons(3).map {|x,y,z| x * y * z }
    nums = [1.2, 2.3, 1.8, 5.2, 3.5]
    nums.any? {|n| n < 1}   # false
    nums.all? {|n| n < 10}  # true
    nums.sort
    nums.sort.take(2)  # 1.9
    nums.sort.drop(2)  # 1.9
    nums.sort.take_while {|n| n < 3}  # 1.9


## Napisy

    :::ruby
    str = "ala ma kota"
    str[2]   # 97, ruby 1.8
    str[2,1] # "a"
    str[2]   # "a", ruby 1.9
    ?a       # 97, ruby 1.8
    ?a       # "a", ruby 1.9
    ?a.ord   # 97

W 1.9 napisy nie są Enumerable, tj. `str.each` nie działa.
Za to mamy:

    :::ruby
    str.each_char   str.chars
    str.each_byte   str.bytes
    mstr = "hello\nworld"
    mstr.each_line {|l| puts l.upcase}
    str.chars.to_a  # ["a", "l", "a", ...]


## Kodowanie

    :::ruby
    str = "witaj świecie'
    str.encoding

Zadawanie kodowania w pliku via *magic comments*:

    :::ruby
    # -*- encoding: utf-8 -*-


## Ruby misz masz

    :::ruby
    str = "ala ma kota"           # 1.8
    str.instance_eval { upcase }
    str.instance_eval { split }
    str.instance_exec(/a/) {|re| split(re) }  # 1.9


# Nieco programowania w Ruby

Klasyczne progtamy z książki Dennisa Ritchie i Briana Kernighana
„Język ANSI C”.

Program *c2f.rb*:

    :::ruby
    celsius = 100
    fahrenheit = (celsius * 9 / 5) + 32
    puts "The result is: "
    puts fahrenheit
    puts "."

Sprawdzamy składnię:

    ruby -cw c2f.rb

Program *c2fi.rb* (interactive):

    :::ruby
    print "Hello. Please enter a Celsius value: "
    celsius = gets
    fahrenheit = (celsius.to_i * 9 / 5) + 32
    print "The Fahrenheit equivalent is "
    print fahrenheit
    puts "."


Reading temperature from data file:

    :::ruby
    puts "Reading Celsius temperature value from data file..."
    num = File.read("temp.dat")
    celsius = num.to_i
    fahrenheit = (celsius * 9 / 5) + 32
    puts "The number is " + num
    print "Result: "
    puts fahrenheit


Writing temperature to file:

    :::ruby
    print "Hello. Please enter a Celsius value: "
    celsius = gets.to_i
    fahrenheit = (celsius * 9 / 5) + 32
    puts "Saving result to output file 'temp.out'"
    fh = File.new("temp.out", "w")
    fh.puts fahrenheit
    fh.close


Two in one: c2f and f2c:

    :::ruby
    print "Please enter a temperature and scale (C or F): "
    str = gets
    exit if str.nil?  or str.empty?
    str.chomp!
    temp, scale = str.split(" ")

    abort "#{temp} is not a valid number." if temp !~ /-?\d+/

    temp = temp.to_f
    case scale
      when "C", "c"
        f = 1.8 * temp + 32
      when "F", "f"
        c = (5.0 / 9.0) * (temp - 32)
    else
      abort "Must specify C or F."
    end

    if f.nil?
      print "#{c} degrees C\n"
    else
      print "#{f} degrees F\n"
    end


## Clases and Modules

    :::ruby
    class Animal
      def initialize
        @health = 0
      end
    end

    class Fox < Animal
      attr_accessor :health
      def self.breeds
        ['snow fox', 'desert fox']
      end
      def initialize
        super
        @health += 5
      end
      def eat(food)
        if likes_food?(food)
          @health += 5
        else
          @health += 1
        end
      end
      def bark
        puts 'wrrrr' if @health > 0
        @health -= 1
      end

      private
      def likes_food?(food)
        food == 'chunky bacon'
      end
    end

    module Invisibility
      def hide
        @visible = false
      end
      def show
        @visible = true
      end
    end

    class Fox
      attr_accessor :visible
      include Invisibility
    end


## Więcej przykładów – silnia i wieża Hanoi

Tak wygląda zwykła implementacja:

    :::ruby
    def fact(n)
      if n == 0
        return 1
      else
        return n*fact(n-1)
      end
    end

    fact(10)

A tak, dodajemy metodę `fact` do klasy *Integer*:

    :::ruby
    class Integer
      def fact
        if self.zero?
          return 1
        else
          return self * (self-1).fact
        end
      end
    end

    10.fact


Implementacja łamigłowki *Wieże Hanoi*,
nie dużo różni się od implementacji w języku *C*:

    :::ruby
    #! /usr/bin/env ruby
    # Towers of Hanoi
    # Copyright (C) 2000 by Michael Neumann (neumann@s-direktnet.de)
    # This is public domain.

    class Towers_of_Hanoi
      A = 0; B = 1; C = 2
      def initialize(n)
        # n = number of stack-elements of the tower
        @n = n
        @stack = []
        @stack[A] = (1..@n).to_a.reverse   # from
        @stack[B] = []                     # to
        @stack[C] = []                     # help
      end
      #
      # "from" and "to" are integers A,B or C.
      # n is the number of elements to put from stack "from"
      # to stack "to" counted from the top of the stack
      #
      def move(from, to, n)
        if n == 1 then
          @stack[to].push(@stack[from].pop)
          output
        elsif n > 1 then
          help = ([A,B,C] - [from,to])[0]  # get help-stack
          move(from, help, n-1)
          move(from, to, 1)
          move(help, to, n-1)
        end
      end
      #
      # run the simulation
      #
      def run
        output
        move(A, B, @n)
      end
      #
      # override this method for user-defined output
      #
      def output
        p @stack
      end
      private :output
    end
    #
    # test-program
    #
    if __FILE__ == $0
      print "Towers of Hanoi\n"
      print "---------------\n"
      print "Please input the height of the tower (e.g. 5): "
      n = readline.to_i
      toh = Towers_of_Hanoi.new(n)
      #
      # prints the three stacks out
      # and waits for keypress
      #
      def toh.output
        for i in 0..2 do
          print "abc"[i].chr, ": "
          p @stack[i]
        end
        readline
      end
      toh.run
    end


## Szablony Erb (i Erubis)

Plik `hello.erb`:

    :::rhtml
    <%% page_title = "Pokaz możliwości szablonów ERB" %>
    <%% salutation = "Kochany programisto," %>
    <html>
    <head>
    <title><%%= page_title %></title>
    </head>
    <body>
    <p><%%= salutation %></p>
    <p>
      Ten przykład demonstruje jak
      działają są szablony ERB.
    </p>
    </body>
    </html>

Po wykonaniu polecenia:

    erb hello.erb

Na `STDOUT` dostajemy:

    :::rhtml
    <% page_title = "Pokaz możliwości szablonów ERB" %>
    <% salutation = "Kochany programisto," %>
    <html>
    <head>
    <title><%= page_title %></title>
    </head>
    <body>
    <p><%= salutation %></p>
    <p>
      Ten przykład demonstruje jak
      działają są szablony ERB.
    </p>
    </body>
    </html>


## Active Record

Tworzymy plik *ar.rb* o zawartości:

    :::ruby
    require 'active_record'
    require 'sqlite3'

    ActiveRecord::Base.establish_connection(
      :adapter => 'sqlite3',
      :database =>  'blog.sqlite3'
    )

    begin
      ActiveRecord::Schema.define do
        create_table :posts do |t|
          t.text :body, :null => false
          t.timestamps
        end
        create_table :comments do |t|
          t.text :body, :null => false
          t.integer :post_id
          t.timestamps
        end
      end
    rescue ActiveRecord::StatementInvalid
      # Do nothing, since the schema already exists
    end

    class Post < ActiveRecord::Base
      has_many :comments
    end
    class Comment < ActiveRecord::Base
      belongs_to :post
    end

    r1 = Post.new
    r1.body = "ruby"
    r1.save
    r2 = Post.create :body => "perl"
    c1 = Comment.create :body => "fajne"
    r1.comments.create :body => "i like ruby"
    r1.comments << c1
    r2.comments << c1


Poniższy kod wpisujemy i uruchamiamy w powłoce Ruby `irb`:

    :::ruby
    require './ar'

    Post.all
    Comments.all

    // SELECT * FROM posts WHERE (posts.id = 1)
    p1 = Post.find 1
    p = Post.find 1, 2
    c1 = Comment.find 1
    c1.body = "xyz"
    c1.save
    Comment.find [1, 2]

    Post.find_by_body "perl"
    Post.find_all_by_body "perl"
    Post.where('body LIKE ?', '%ub%') # SQL fragment
    what = 'ub'
    Post.where('body LIKE ?', "%#{what}%")

    params = {}
    params[:start_date] = Time.now - 4.days - 5.hours
    params[:end_date] = Time.now
    Post.where("created_at >= :start_date AND created_at <= :end_date",
      {:start_date => params[:start_date], :end_date => params[:end_date]})

    Post.where(:created_at => (Time.now.midnight - 1.day)..Time.now.midnight)
    Post.order("created_at DESC")

    # Time in Ruby
    t = Time.parse "2010-02-31 12:00:12 0200"
    t.class
