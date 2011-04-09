# -*- coding: utf-8 -*-

# sudo gem install ambethia-smtp-tls -v '1.1.2' --source http://gems.github.com

require 'rubygems'
require 'action_mailer'
require 'smtp-tls'

require 'yaml'

private = YAML.load(IO.read('../../../../../private.yaml'))['gmail']

ActionMailer::Base.delivery_method = :smtp

class SimpleMailer <  ActionMailer::Base
  def simple_message(recipient)
    from 'wlodek.bzyl@gmail.com'
    recipients recipient
    subject 'Tę wiadomość wysłano z Gmail'
    body 'To naprawdę działa!'
  end
end

ActionMailer::Base.smtp_settings = {
  :address => 'smtp.gmail.com',
  :domain => 'gmail.com',
  :port => 587,
  :user_name => private['login'],
  :password => private['password'],
  :authentication => 'plain',
  :enable_starttls_auto => true
}

SimpleMailer.deliver_simple_message('matwb@ug.edu.pl')
