# -*- coding: utf-8 -*-

require 'mail'

mail = Mail.new do
  to 'matwb@ug.edu.pl'
  from 'wbzyl@inf.ug.edu.pl'
  subject 'Tę wiadomość wysłano z localhost'
  body File.read('body.txt')
  add_file :filename => 'butterfly.jpg', :content => File.read('images/butterfly.jpg')
end

mail.deliver!
