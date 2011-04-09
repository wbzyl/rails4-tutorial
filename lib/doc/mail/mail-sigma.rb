# -*- coding: utf-8 -*-

require 'rubygems'
require 'action_mailer'
require 'mime/types'

ActionMailer::Base.smtp_settings = {
  :address => 'inf.ug.edu.pl',
  :port => '25',
  :domain => 'inf.ug.edu.pl',
  :user_name => 'wbzyl',
  :password => 'sekret',
  :authentication => :login
}

class Notification < ActionMailer::Base
  #default :charset => 'UTF-8'
  
  def directory_dump(recipient, directory=Dir.pwd)
    from 'wbzyl@inf.ug.edu.pl'
    content_type 'text/plain; charset=utf-8'
    recipients recipient
    subject "Zdjęcia z wakacji"

    message = %{Zdjęcia z katalogu: #{directory}:\n\n}
    Dir.glob('*.jpeg') do |f|
      message += "\t" + File.join(directory, f) + "\n"
    end

    body message
  end
end

Notification.directory_dump('matwb@ug.edu.pl').deliver
