PasswordNib = "#{ENV["TM_BUNDLE_SUPPORT"]}/nibs/RequestPassword.nib"
  
module Authentication

  def self.dialog(blogger,user)
    promptParams = {'storePassword' => false, 
                    'string' => '',
                    'title' => "#{user}'s google password",
                    'prompt' => 'Please type in your google password:'}
    UI.dialog(:nib => PasswordNib, :parameters => promptParams) do |window|
      repeat = false
      window.wait_for_input do |params|
        password = params['returnArgument']
        begin
          blogger.authenticate(user, password)
          repeat = false # correct password
        rescue Exception => e
          window.parameters = {'title' => "Incorrect Password",
                               'prompt' => "The password you typed is incorrect."}
          repeat = true
        end
        
        unless params['storePassword'] == 0
          Keychain.save_passwd(user,password)
        end
        repeat
      end # end of wait
    end # end of dialog
  end
  
end
  
  
module Keychain
  def self.get_passwd(user)
    `security 2>&1 >/dev/null find-generic-password -ga #{user} -s 'blogger-textmate' | \
     ruby -e 'print $1 if STDIN.gets =~ /^password: "(.*)"$/'`
  end

  def self.save_passwd(user,password)
    `security add-generic-password -a #{user} -s 'blogger-textmate' -p #{password}`
  end
end