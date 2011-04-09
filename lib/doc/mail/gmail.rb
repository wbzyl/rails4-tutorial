# -*- coding: utf-8 -*-

require 'mail'
require 'yaml'

raw_config = File.read("#{ENV['HOME']}/.credentials/smtp.yml")
SMTP_CONFIG = YAML.load(raw_config)['development'].symbolize_keys

Mail.defaults do
  delivery_method :smtp, {
    :address => SMTP_CONFIG[:address],
    :port => SMTP_CONFIG[:port],
    :domain => SMTP_CONFIG[:domain],
    :user_name => SMTP_CONFIG[:user_name],
    :password => SMTP_CONFIG[:password],
    :authentication => SMTP_CONFIG[:authentication],
    :enable_starttls_auto => true
  }
end

mail = Mail.new do
  to 'matwb@ug.edu.pl'
  from 'wlodek.bzyl@gmail.com'
  subject 'Tę wiadomość wysłano z Gmail'
  body File.read('body.txt')
  add_file :filename => 'butterfly.jpg', :content => File.read('images/butterfly.jpg')
end

mail.deliver!
