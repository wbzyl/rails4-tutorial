# -*- coding: utf-8 -*-

require 'rubygems'
require 'action_mailer'
require 'mime/types'
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
  def directory_dump(recipient, directory=Dir.pwd)
    from 'wbzyl@inf.ug.edu.pl'
    content_type 'text/plain; charset=utf-8'
    recipients recipient
    subject "zdjęcia z katalogu: #{directory}"
    body %{Zdjęcia z katalogu: "#{directory}":}
    Dir.glob('*.jpeg') do |f|
      path = File.join(directory, f)
      attachment('image/jpeg') do |a|
        a.body = File.read(path)
        a.filename = f
        a.transfer_encoding = 'base64'
      end
    end
  end
end

#puts Notification.create_directory_dump('matwb@ug.edu.pl', Dir.pwd)

Notification.deliver_directory_dump('matwb@ug.edu.pl')

__END__

removing file from repo:
  
git filter-branch --index-filter \
  'git rm --cached --ignore-unmatch private.yaml' merge-point..HEAD

# remove the temporary history git-filter-branch otherwise leaves behind for a long time
rm -rf .git/refs/original/ && git reflog expire --all &&  git gc --aggressive --prune

git push
#git push -f
