# -*- coding: utf-8 -*-

require 'rubygems'
require 'mail'

login = 'matwb'
password = 'alamakota'

Mail.defaults do
  pop3 'julia.univ.gda.pl', 110 do
    user login
    pass password
  end
end

emails = Mail.first(:count => 4, :order => :asc) do |email|
  puts email.date.to_s
  puts email.from
  puts email.subject.to_s
#  puts email.body.to_s[0..40]
#  puts email.message_id
#  puts email.to
#  puts email.cc
end
