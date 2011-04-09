# -*- coding: utf-8 -*-

require 'rubygems'
require 'action_mailer'
require 'yaml'

# wczytujemy login + hasło z pliku private.yaml
#
# ---
# sigma: 
#   :login: wbzyl
#   :password: 'alamakota'
# julia:
#   :login: matwb
#   :password: 'razdwatrzy'

private = YAML.load(IO.read('../../../../../private.yaml'))

ActionMailer::Base.smtp_settings = {
  :address => 'inf.ug.edu.pl',
  :port => 25,
  :domain => 'ug.edu.pl',
  :user_name => private['sigma'][:login],
  :password => private['sigma'][:password],
  :authentication => :login
}

class Notification < ActionMailer::Base
  def signup_message(recipient)
    from 'wbzyl@inf.ug.edu.pl'
    content_type 'text/plain; charset=utf-8'
    recipients recipient
    subject 'action mailer test: 4'
    body 'Treść emaila #4.'
  end
end

puts Notification.create_signup_message('matwb@ug.edu.pl')

Notification.deliver_signup_message('matwb@ug.edu.pl')
