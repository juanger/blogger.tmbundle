require 'rubygems'
require 'Blogger'
require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/authentication.rb"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/UI"

include TextMate

PublishNib = "#{ENV["TM_BUNDLE_SUPPORT"]}/nibs/Publish.nib"

UI.dialog(:nib => PublishNib, 
          :parameters => {'blogs' => [], 'hideProgressIndicator' => false}) do |dialog|

  username = ENV['GDATA_USERNAME']
  password = Keychain.get_passwd(username)

  account = Blogger::Account.new()

  if password.empty?
    Authentication.dialog(account,username)
  else
    account.authenticate(username,password)
  end
  
  # account = Blogger::Account.new(username, password)

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
    # puts params.inspect
    if button == 'Cancel'
      puts "<h1>Publishing cancelled</h1>"
    else
      #FIXME Obviously, this is not acceptable.
      post = Blogger::Post.new(:title => 'DRAFT FROM TEXTMATE', :categories => params['categories'])
      post.draft = true  # FIXME Turn this off after testing
      post.content = open(ENV['TM_FILEPATH']).read
      # FIXME Formatting?
      account.post(blog_id, post)
      # FIXME Restore link below
      puts "<h1>Your post has been published!!</h1>"
    end
    false
  end # end of wait
  
end # End of Publish dialog