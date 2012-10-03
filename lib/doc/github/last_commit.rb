# -*- coding: utf-8 -*-
#
# gem install github_api ansi

require 'github_api'
require 'ansi/code'  # http://rubydoc.info/gems/ansi/frames

include ANSI::Code

require 'time'
require 'csv'

# ----

github = Github.new

# dane wczytać z pliku

repos = [
  { login: 'wbzyl', name: 'rails4-tutorial'},
  { login: 'wbzyl', name: 'sp-tutorial'},
  { login: 'wbzyl', name: 'spa-tutorial'},
  { login: 'wbzyl', name: 'nosql-tutorial'}
]

repos.each do |repo|
  # get the last commit info
  author = github.repos.commits.list(repo[:login], repo[:name], page: 1, per_page: 1)[0].commit.author
  date = DateTime.iso8601(author.date).to_date
  # 7 dni == tydzień
  procrastinate = date < Date.today.prev_day(8) ? red(date) : date
  puts "#{procrastinate} by #{yellow author.email} (#{author.name})"
end

# DateTime.iso8601(date).to_time < Time.now - 7*24*60*60
# DateTime.iso8601(date).to_date < Date.today.prev_day(7)
