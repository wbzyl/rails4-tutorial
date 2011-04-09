# -*- coding: utf-8 -*-

require 'rubygems'
require 'mail'

login = 'wbzyl'
password = 'alamakota'

Mail.defaults do
  smtp 'inf.ug.edu.pl', 25 do
    user login
    pass password
  end
end

mail = Mail.deliver do
  from 'wbzyl@inf.ug.edu.pl'
  to 'matwb@ug.edu.pl'
  content_type 'text/plain; charset=UTF-8'

  subject 'This is a test email: 30'
  body File.read('body.txt')

# add_file 'motylek.jpeg'
#   albo tak
# add_file :filename => 'motylek.jpeg',
#   :data => File.read('motylek.jpeg'),
#   :content_transfer_encoding => 'base64'
end
