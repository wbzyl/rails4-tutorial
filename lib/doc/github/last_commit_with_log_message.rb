# -*- coding: utf-8 -*-
#
# gem install github_api ansi

require 'github_api' # http://rubydoc.info/gems/github_api/frames
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
  user_name = repo[:login]
  repo_name = repo[:name]

  # get the last commit
  last_commit = github.repos.commits.list(user_name, repo_name, page: 1, per_page: 1)[0]

  uid = last_commit.author.id

  author = last_commit.commit.author
  # puts author.keys
  date = DateTime.iso8601(author.date).to_date
  # 7 dni == tydzień
  procrastinate = date < Date.today.prev_day(8) ? red(date) : date
  puts "#{procrastinate} #{yellow(user_name + '/' + repo_name)} (#{author.name}, #{author.email}, uid #{cyan(uid)})"

  # log message
  message = last_commit.commit.message
  puts "\t#{message}"

end
