require 'rubygems'
require 'gdata/blogger'
require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/gdata_extension"
require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/post.rb"
require "#{ENV["TM_BUNDLE_SUPPORT"]}/lib/authentication.rb"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/UI"

include TextMate

PublishNib = "#{ENV["TM_BUNDLE_SUPPORT"]}/nibs/Publish.nib"
TextMode = ENV['TM_MODE'].scan(/Post — (.*)/)[0][0]

UI.dialog(:nib => PublishNib, 
        :parameters => {'blogs' => [], 'hideProgressIndicator' => false}) do |dialog|
  
  post = Post.new(ENV['TM_FILEPATH'], TextMode)
  
  # Authenticate
  blogger = GData::Blogger.new('')
  
  user = ENV['GDATA_USER']
  password = Keychain.get_passwd(user)
  
  if password.empty?
    Authentication.dialog(blogger,user)
  else
    blogger.authenticate(user,password)
  end
  
  feed = Hpricot.parse blogger.metafeed
  
  blogs = []
  # categories = []
  
  # Get the blogs list and categories
  (feed/:entry).each do |blog|
    id = (blog/:id).inner_html
    title = (blog/:title).inner_html
    blogs << {'name' => title, 'id' => id.scan(/blog-(\d*)/)[0][0]}
    # TODO: Find a way to show existing categories in the nib
    # (blog/:category).each do |cat|
    #   categories << { 'name' => cat[:term]}
    # end
  end
  
  # re-display de dialog
  dialog.parameters = {'blogs' => blogs,'hideProgressIndicator' => true}
  
  dialog.wait_for_input do |params|
    blog_id = params['returnArgument']
    button = params['returnButton']
    # puts params
    if blog_id
      blogger.blog_id = blog_id
      post.categories = params['categories']
      false
    end
    false
  end
  
  blogger.entry(post.title, post.content, post.categories)
end # End of Publish dialog
