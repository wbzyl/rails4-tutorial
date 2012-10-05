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
  # get the last commit info
  author = github.repos.commits.list(repo[:login], repo[:name], page: 1, per_page: 1)[0].commit.author
  # puts author.keys
  date = DateTime.iso8601(author.date).to_date
  # 7 dni == tydzień
  procrastinate = date < Date.today.prev_day(8) ? red(date) : date
  puts "#{procrastinate} by #{yellow author.email} (#{author.name})"
end

# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/date/rdoc/DateTime.html#method-c-iso8601
# http://www.ruby-doc.org/stdlib-1.9.3/libdoc/date/rdoc/Date.html
# DateTime.iso8601(date).to_time < Time.now - 7*24*60*60
# DateTime.iso8601(date).to_date < Date.today.prev_day(7)

# Misc
#
# compare = github.repos.commits.compare('wbzyl', 'rails4-tutorial', "fcc512a2d6d48b3e346b63a14c9c5f3f9356b48e", "master")
# compare.keys ["total_commits", "permalink_url", "html_url","diff_url", "patch_url", "files", "commits", "url", ...]
#
# compare

# files = github.repos.commits.compare('wbzyl', 'rails4-tutorial', "fcc512a2d6d48b3e346b63a14c9c5f3f9356b48e", "master").files
# files[0].keys  #=> ["filename", "status", "raw_url", "additions", "sha", "patch", "deletions", "blob_url", "changes"]
#
# files[0].filename
# files[0].patch
# files[0].blob_url
