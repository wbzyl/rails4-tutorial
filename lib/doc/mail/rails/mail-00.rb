# -*- coding: utf-8 -*-

require 'rubygems'

# utwórz wiadomość

require 'mail'
mail = Mail.new do
  from 'wbzyl@inf.ug.edu.pl'
  to 'matwb@ug.edu.pl'
  content_type 'text/plain; charset=UTF-8'
  content_transfer_encoding '8bit'
  mime_version '1.0'
  
  subject 'This is a test email: #100'

  body File.read('body.txt')
end

puts mail.to_s

# wyślij ją

require 'net/smtp'

login = 'wbzyl'
password = 'alamakota'

Net::SMTP.start('inf.ug.edu.pl', 25, 'inf.ug.edu.pl', login, password, :login) do |smtp|
  smtp.send_message mail.to_s, mail.from, mail.to
end 
