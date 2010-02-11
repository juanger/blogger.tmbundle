require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/setup"
require "post"
require 'blogger'
require "authentication"
require "UI"

include TextMate

PublishNib = "#{ENV["TM_BUNDLE_SUPPORT"]}/nibs/Publish.nib"
username = ENV['BLOGGER_USERNAME']

unless username
  UI.alert(:warning, 'You haven\'t setup your username', 'Please set the BLOGGER_USERNAME variable in preferences to use this bundle', 'OK')
  exit
end

UI.dialog(:nib => PublishNib, 
          :parameters => {'blogs' => [], 'hideProgressIndicator' => false}) do |dialog|
  
  password = Keychain.get_passwd(username)
  account = Blogger::Account.new('default','','')

  if password.empty?
    Authentication.dialog(account,username)
  else
    account.authenticate(username,password)
  end

  # Get the blogs list
  blogs = []
  account.blogs.each do |blog|
    blogs << {'name' => blog.title, 'id' => blog.id}
  end
  
  ##
  # Re-display de dialog
  ##
  
  dialog.parameters = {'blogs' => blogs,'hideProgressIndicator' => true}
  button = ""
  dialog.wait_for_input do |params|
    blog_id = params['returnArgument']
    button = params['returnButton']
    if button == 'Cancel'
      puts "<h1>Publishing cancelled</h1>"
    else
      post = Post.new()
      post.content = File.read(ENV['TM_FILEPATH'])
      account.post(blog_id, post)
      # FIXME Restore link below
      puts "<h1>Your post has been published!!</h1>"
    end
    false
  end # end of wait
  
end # End of Publish dialog